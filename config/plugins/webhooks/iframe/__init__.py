import random

gcc_announcement = {
    'target': 'https://goo.gl/forms/lcPoMt4iZ8hwcdM12?refresh=1m&orgId=1&from=now-3h&to=now&panelId=38',
    'announce': 'Vote for your favorite trainings <em>HERE & NOW</em>!'
}

def main(trans, webhook, params):
    return random.choice([
        {
            'src': 'https://usegalaxy-eu.github.io/galaxy/news.html',
            'height': 1000,
            'title': 'Galactic News',
        },
        {
            'src': 'https://stats.usegalaxy.eu/dashboard-solo/db/galaxy?refresh=1m&orgId=1&from=now-3h&to=now&panelId=38',
            'height': 1000,
            'title': 'Galaxy Queue (past 3 hours)',
        },
        {
            'src': 'https://usegalaxy-eu.github.io/galaxy/events.html',
            'height': 1000,
            'title': 'Upcoming Events',
        },
        {
            'src': 'https://galaxyproject.org/events/gcc2019/',
            'height': 1000,
            'title': 'Galaxy Community Conference 2019 - Freiburg, Germany',
            'announcement': gcc_announcement
        },
        {
            'src': 'https://goo.gl/forms/lcPoMt4iZ8hwcdM12?refresh=1m&orgId=1&from=now-3h&to=now&panelId=38',
            'height': 1000,
            'title': 'Galaxy Community Conference 2019 - Vote on Trainings',
            'announcement': gcc_announcement
        },
        {
            'src': 'https://galaxyproject.org/events/gcc2019/training/#training-at-gcc2019',
            'height': 1000,
            'title': 'Galaxy Community Conference 2019 - Training Topics',
            'announcement': gcc_announcement
        }
    ])
