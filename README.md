# C Code Develop
C Code Develop App References (iOS, AppStore)
> Thanks you for watching this project.  
We have TestFlight version product for this, you can try more expermental features for this App if you want.  
[TestFlight Download Link (Free)](https://testflight.apple.com/join/KoaMeGUJ)   
[AppStore Download Link ($0.99)](https://apps.apple.com/app/id1503486606)  
[Our APIDoc Website](https://docs.forgetive.org)  

Notice
---
**!! HELP WANTED !!**  
> If you need more header or functions, please implement more function in the /syscall directory. If you implementation **just need apis that app already have**, please write api's definition in the /syscall/header directory, and implement it in /syscall/header/intrinsic directory. **Otherwise (You API need other APIs that app not currently have)**, please implement the API in /syscall/builtin directory. **And Then**, just open a pull request and describe your new APIs. A big thank for you to help me improve this App.

APIs implements in /syscall/builtin will compile to machine binary code when App compile, in /syscall/headers/intrinsic will be package as source code on App build time and use interpreter to evaluate it. That means, APIs in /syscall/builtin will run much quick than others way. But you shouldn't use static or global variables in /syscall/builtin, because many thread (We use thread to simulate process) will access same memory, that will cause runtime jams.

If you find a bug in the latest version of TestFlight or AppStore, please issue me, I will fix it as soon as possible, thanks!!  
If this project works for you, please given me a star :)
