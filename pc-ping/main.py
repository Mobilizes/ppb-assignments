from firebase_admin import initialize_app, credentials, firestore
import pygame as pg


def main():
    cred = credentials.Certificate(
        "ets-ppb-1512-firebase-adminsdk-fbsvc-6095ea91df.json"
    )

    initialize_app(cred)

    db = firestore.client()

    pg.init()
    pg.display.set_mode((320, 240))
    pg.display.set_caption("ppb pc ping")

    pg.mixer.init()
    alarm = pg.mixer.Sound("bokudan.mp3")
    alarm.play()

    previous_data_length = -1

    running = True
    while running:
        pg.time.delay(100)
        for event in pg.event.get():
            if event.type == pg.QUIT:
                running = False

        data = db.collection("histories").where("userId", "==", "XxcEKUGHFx7WuueyzFi3")
        data_length = len(data.get())

        if data_length > previous_data_length and previous_data_length != -1:
            alarm.play()

        previous_data_length = data_length

    pg.quit()


if __name__ == "__main__":
    main()
