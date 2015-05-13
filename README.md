Create a simple color picker for iOS.

To impliment add the files into your project.
Also add the quart QuartzCore.framework & UIKit.framework

To invoke the switcher:

'colorPicker = [customColorPicker new];
[self.view addSubview:colorPicker];'

The picker will remove itself form the screen.

To update the color have the tag of the button's tag to 1000. This will ensure the button's background color will update the the picked color.