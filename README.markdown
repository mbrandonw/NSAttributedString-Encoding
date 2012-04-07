#NSAttributedString+Encoding - To NSData and back

This category adds two methods to `NSAttributedString` that allows you to easily convert instances to `NSData` and back. For example,

    NSAttributedString *string = [[NSAttributedString alloc] initWithString:... attributes:...];
    NSData *encoded = [string convertToData];
    NSAttributedString *decoded = [NSAttributedString attributedStringWithData:encoded];
    
Unfortunately, it is not necessarily true that `[string isEqualToAttributedString:decoded]` due to some unsupported features of attributed strings. Right now we do not properly encode glyph attributes, run delegates (whatever the hell those are), and the tab stops specificer of paragraph styles. However, the decoded string is similar enough to the original that you probably won't even notice when rendering.

##Installation

We love [CocoaPods](http://github.com/cocoapods/cocoapods), so we recommend you use it.

##Author

Brandon Williams  
[@mbrandonw](http://www.twitter.com/mbrandonw)  
[brandon@opetopic.com](brandon@opetopic.com)  
[www.opetopic.com](http://www.opetopic.com)