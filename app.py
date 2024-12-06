import pyautogui
import random
import time
import threading
import tkinter as tk
from pynput import keyboard

class FreemausApp:
    def __init__(self):
        self.should_stop = False
        self.status_window = None
        self.timer_thread = None
        self.setup_gui()

    def setup_gui(self):
        self.root = tk.Tk()
        self.root.title("Freemaus Status")
        self.root.geometry("300x100+1000+100")
        self.label = tk.Label(self.root, text="Freemaus is taking care of it. Hit any key to disable")
        self.label.pack(pady=10)
        self.timer_label = tk.Label(self.root, text="Time Until Next Click: Calculating...")
        self.timer_label.pack(pady=5)
        self.root.protocol("WM_DELETE_WINDOW", self.on_close)

    def on_close(self):
        # Close event handler to stop the application properly
        self.should_stop = True
        self.root.destroy()

    def start(self):
        # Start the listener for keyboard events
        listener = keyboard.Listener(on_press=self.on_key_press)
        listener.start()

        # Start the mouse control in a separate thread
        self.timer_thread = threading.Thread(target=self.schedule_next_mouse_action)
        self.timer_thread.start()

        # Start the tkinter main loop
        self.root.mainloop()

    def on_key_press(self, key):
        # Stop mouse movement when any key is pressed
        self.should_stop = True
        self.root.destroy()

    def schedule_next_mouse_action(self):
        while not self.should_stop:
            time_until_next_click = random.randint(20, 120)
            self.update_timer_label(time_until_next_click)
            time.sleep(time_until_next_click)
            if not self.should_stop:
                self.move_and_click_mouse()

    def update_timer_label(self, seconds):
        self.label.config(text="Freemaus is taking care of it. Hit any key to disable")
        self.timer_label.config(text=f"Time Until Next Click: {seconds} seconds")

    def move_and_click_mouse(self):
        # Move the mouse to a random position and click
        screen_width, screen_height = pyautogui.size()
        random_x = random.randint(0, screen_width)
        random_y = random.randint(0, screen_height)
        pyautogui.moveTo(random_x, random_y, duration=random.uniform(0.5, 2.0))
        pyautogui.click()

if __name__ == "__main__":
    app = FreemausApp()
    app.start()
