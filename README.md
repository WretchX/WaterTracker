**WaterTracker**  
An open-source daily water tracker  for Windows written completely in AutoItv3, with customizable hydration reminders.

**HOW TO INSTALL:**
1. Download AutoIt if you don't already have it installed (**11.7mb**). You will need this to compile the code.
https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3-setup.exe
2. Be sure the **.au3 file association** is checked during installation.
3. _Make sure you've unzipped WaterTracker_. In the WaterTracker directory, right-click "**WaterTracker.au3**" and then "**Compile Script**"
4. Run WaterTracker.exe. _If you wish to run the program from outside the program's directory, create a shortcut_.

![image](https://user-images.githubusercontent.com/84418728/173700393-a4960b0c-6b5f-4058-b2ec-20e77c75174e.png)

**HOW TO USE:**  
This program keeps track of your water intake throughout the day. There are 3 ways to add water amounts:
- By clicking the 3 buttons (Labeled 16, 20, 32oz. by default)
- By typing in a custom amount under "**Quick Add**", and then clicking "**Add**"
- By dragging the **slider** to the amount you wish to add, and then clicking "**Add**"

You can set reminders to drink water by clicking "**Reminders**"  
- Click "**New**" in the _Reminders_ window, and enter the time you'd like the reminder to go off. Click "**Add**" to add the reminder.
- Up to 10 daily reminders can be added.
- 2 options are available for the reminder alerts. A **sound** to play, a **popup**, or **both**. If neither are selected, your reminders will essentially do nothing, so be _sure to have at least 1 selected_.

You can adjust some of the values in WaterTracker via **Options**  
- _Daily Goal_ is the total amount of water you're trying to drink each day.
- _Logging Enabled_ will automatically log your progress in **dailylogs.txt** at 3:00AM, as long as the program's open.
- _X minimizes to tray_ - checking this box will allow Water Tracker to minimize to tray when you click the X button, instead of closing the program. Keep in mind, clicking "**Exit**" will always exit the program no matter what.
- _Custom values_ - These 3 input boxes will allow you to change the value in ounces of the 3 quickbuttons on the main program window.
- Always click "**Save**" to apply changes made. Clicking X will not save changes made in Options.

"**Reset**" will simply clear the day's data. Your options will not be afected.
