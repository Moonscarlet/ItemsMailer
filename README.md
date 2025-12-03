# ItemsMailer

A simple World of Warcraft 3.3.5a (Ascension) addon that automatically mails specific items to a configured recipient when you open the mailbox.

## Features

- **Auto-Detect**: Scans your bags for configured items when you open the mailbox.
- **Auto-Send**: If items are found, it automatically switches to the "Send Mail" tab, attaches the items (up to 12 stacks), and sends them.
- **Safety Check**: Does not attempt to send mail if the current character is the configured recipient.
- **Reporting**: Prints a detailed report of sent items and stack counts to your chat window.
- **Auto-Close**: Automatically closes the mail window after sending.

## Configuration

Configuration is done directly in the `ItemsMailer.lua` file.

1. Open `ItemsMailer.lua` in any text editor.
2. Edit the **CONFIGURATION** section at the top of the file:

```lua
-- CONFIGURATION
local RECIPIENT_NAME = "YourAltName" -- The character to receive the items
local WANTED_ITEMS = {
    "Runecloth",        -- Item Name
    "Mooncloth",
    "Arcanite Bar",
    12345,              -- You can also use Item IDs
}
-- END CONFIGURATION
```

## Installation

1. Download or clone this repository.
2. Place the `ItemsMailer` folder into your WoW directory:  
   `\Interface\AddOns\`
3. Structure should look like:
   `\Interface\AddOns\ItemsMailer\ItemsMailer.toc`
   `\Interface\AddOns\ItemsMailer\ItemsMailer.lua`

## Usage

1. Log in to a character that holds the items you want to send.
2. Go to a mailbox and open it.
3. If you have any of the configured items, the addon will automatically mail them to your recipient and close the window.
4. If you don't have any items, the mailbox will function normally.

