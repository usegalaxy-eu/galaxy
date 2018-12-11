import random


def main(trans, webhook, params):
    return random.choice([
        {
            'src': 'https://usegalaxy-eu.github.io/galaxy/gxnews/',
            'height': 1000,
            'title': 'Galactic News',
        },
        {
            'src': 'https://stats.usegalaxy.eu/dashboard-solo/db/galaxy?refresh=1m&orgId=1&from=now-3h&to=now&panelId=38',
            'height': 1000,
            'title': 'Galaxy Queue (past 3 hours)',
        },
        {
            'src': 'https://usegalaxy-eu.github.io/galaxy/gxevents/',
            'height': 1000,
            'title': 'Upcoming Events',
        }
    ])
