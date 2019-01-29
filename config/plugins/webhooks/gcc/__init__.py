import random


def main(trans, webhook, params):
    return random.choice([
        {
            'src': 'https://galaxyproject.org/events/gcc2019/',
            'height': 1000,
            'title': 'Galaxy Community Conference 2019 - Freiburg, Germany',
        },
        {
            'src': 'https://goo.gl/forms/lcPoMt4iZ8hwcdM12?refresh=1m&orgId=1&from=now-3h&to=now&panelId=38',
            'height': 1000,
            'title': 'Galaxy Community Conference 2019 - Vote on Trainings',
        },
        {
            'src': 'https://galaxyproject.org/events/gcc2019/training/#training-at-gcc2019',
            'height': 1000,
            'title': 'Galaxy Community Conference 2019 - Training Topics',
        }
    ])
