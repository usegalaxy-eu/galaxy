import random

<<<<<<< HEAD
gcc_announcement = {
    'target': 'https://goo.gl/forms/lcPoMt4iZ8hwcdM12?refresh=1m&orgId=1&from=now-3h&to=now&panelId=38',
    'announce': 'Vote for your favorite trainings <em>HERE & NOW</em>!'
}

=======
>>>>>>> 895895fd7e7d731bd96a225280b4719f3ce708f9
pages = [
    {
        'src': 'https://usegalaxy-eu.github.io/galaxy/news.html',
        'height': 1000,
        'title': 'Galactic News',
        'weight': 0.5,
    },
    {
<<<<<<< HEAD
        'src': 'http://teacheng.illinois.edu/SequenceAlignment/',
        'height': 1000,
        'title': 'Sequence Alignment: The Game!',
        'weight': 0.5,
=======
        # TODO: need to self-host
        'src': 'http://teacheng.illinois.edu/SequenceAlignment/',
        'height': 1000,
        'title': 'Sequence Alignment: The Game!',
        'weight': 0.0,
>>>>>>> 895895fd7e7d731bd96a225280b4719f3ce708f9
    },
    {
        'src': 'https://stats.galaxyproject.eu/dashboard-solo/db/galaxy?refresh=1m&orgId=1&from=now-3h&to=now&panelId=38',
        'height': 1000,
        'title': 'Galaxy Queue (past 3 hours)',
        'weight': 0.5,
    },
    {
        'src': 'https://usegalaxy-eu.github.io/galaxy/events.html',
        'height': 1000,
        'title': 'Upcoming Events',
        'weight': 0.5,
    },
    {
<<<<<<< HEAD
        'src': 'https://galaxyproject.org/events/gcc2019/',
        'height': 1000,
        'title': 'Galaxy Community Conference 2019 - Freiburg, Germany',
        # 'announcement': gcc_announcement,
        'weight': 1,
    },
    {
        'src': 'https://galaxyproject.eu/livestream-plain.html',
        'height': 1000,
        'title': 'Galaxy Community Conference 2019 - Livestream!',
        'weight': 2,
    },
    {
        'src': 'https://gcc2019.sched.com/',
        'height': 1000,
        'title': 'Galaxy Community Conference 2019 - Schedule',
        # 'announcement': gcc_announcement,
        'weight': 2,
=======
        'src': 'https://usegalaxy.eu/gapars-experiment/',
        'height': 1000,
        'title': 'Citizen Science Experiment!',
        'weight': 0.5,
>>>>>>> 895895fd7e7d731bd96a225280b4719f3ce708f9
    }
]

weighted_pages = [(page, page['weight']) for page in pages]

def weighted_choice(choices):
    """Weighted random distribution. Given a list like [('a', 1), ('b', 2)]
    will return a 33% of the time and b 66% of the time."""
    # http://stackoverflow.com/a/3679747
    total = sum(w for c, w in choices)
    r = random.uniform(0, total)
    upto = 0
    for c, w in choices:
        if upto + w >= r:
            return c
        upto += w


def main(trans, webhook, params):
    return weighted_choice(weighted_pages)
<<<<<<< HEAD


# if __name__ == '__main__':
    # import json
    # print(json.dumps(main(None, None, None)))
=======
>>>>>>> 895895fd7e7d731bd96a225280b4719f3ce708f9
