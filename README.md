# CONTACT PHOTO UPLOADER - LWC

LWC for Salesforce to add a photo of a Contact / person on the Contact page.

## Install:
- Deploy the Class and LWC folder to your org
- Add the LWC to the page

## Setup Notes:
- Only JPG, JPEG and PNG formats are allowed.
- Configure the size of the picture using LWC parameters
- You can specify a starting image in the LWC parameter or set it to blank.
- Image uploaded are stored in ContentVersion, attached to the Contact Record.
- Image uploaded is named "ContactPhoto"
- Only one Contact Photo is allowed at a time.  Delete before changing.

## TO DO:
- Finish Test class.
- Add screenshots
