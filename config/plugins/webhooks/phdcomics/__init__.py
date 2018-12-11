import urllib
import re
import random
import logging
from bs4 import BeautifulSoup

log = logging.getLogger(__name__)

cache = {}
latest_id = 0


def get_by_id(random_id, webhook):
    random_id = random.randint(1, webhook.config['latest_id'])
    url = 'http://www.phdcomics.com/comics/archive.php?comicid=%d' % \
        random_id
    content = urllib.urlopen(url).read()
    soup = BeautifulSoup(content, 'html.parser')
    comic_img = soup.find_all('img', id='comic2')
    print(url)
    print(comic_img)

    try:
        comic_src = comic_img[0].attrs.get('src')
    except IndexError:
        pattern = '<img id=comic2 name=comic2 src=([\w:\/\.]+)'
        comic_src = re.search(pattern, content).group(1)
    print(comic_src)

    # urls look like
    # http://phdcomics.com/comics/archive/phd092017s.gif
    comic_src = comic_src.replace('http://phdcomics.com', 'https://usegalaxy.eu/external/phdcomics')
    comic_src = comic_src.replace('http://www.phdcomics.com', 'https://usegalaxy.eu/external/phdcomics')
    return comic_src


def main(trans, webhook, params):
    try:
        # Get latest id
        if 'latest_id' not in webhook.config.keys():
            url = 'http://phdcomics.com/gradfeed.php'
            content = urllib.urlopen(url).read()
            soap = BeautifulSoup(content, 'html.parser')
            comics = [
                g.contents[0]
                for g in soap.find_all('guid')
            ]
            comics = [int(g[g.index('?f=') + 3:]) for g in comics]
            webhook.config['latest_id'] = max(comics)

        random_id = random.randint(1, webhook.config['latest_id'])
        comic_url = get_by_id(random_id, webhook)
        print(comic_url)
        return {'success': True, 'error': '', 'src': comic_url}

    except Exception as e:
        return {'success': False, 'error': str(e), 'src': ''}
