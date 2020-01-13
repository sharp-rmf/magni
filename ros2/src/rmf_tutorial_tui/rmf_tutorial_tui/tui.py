import npyscreen
import subprocess
import pathlib


class rmfTutorialTui(npyscreen.Form):
    def afterEditing(self):
        self.parentApp.setNextForm(None)

    def button_mir_demo(self):
        subprocess.call(
            [str(pathlib.Path(__file__).parent.absolute()) + "/launch-mir-demo.sh"])

    def button_scheduler(self):
        subprocess.call(
            [str(pathlib.Path(__file__).parent.absolute()) + "/launch-scheduler.sh"])

    def create(self):
        self.button_mir_demo_handle = self.add(
            npyscreen.ButtonPress, name='MiR Demo', when_pressed_function=self.button_mir_demo)
        self.button_scheduler_handle = self.add(
            npyscreen.ButtonPress, name='Launch Scheduler', when_pressed_function=self.button_scheduler)


class MyApplication(npyscreen.NPSAppManaged):
    def onStart(self):
        self.addForm('MAIN', rmfTutorialTui, name='RMF Tutorial Button Panel')


def main(args=None):
    TestApp = MyApplication().run()


if __name__ == '__main__':
    main()
