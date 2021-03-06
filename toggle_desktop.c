#include <X11/Xatom.h>
#include <X11/Xlib.h>

#include <stdio.h>
#include <stdlib.h>

// Utility that shows the desktop if windows are in focus, or unshows the desktop if
// the desktop is already showing. Essentially, what you'd normally bind to Win+D.
//
// Source:
//   https://www.linuxquestions.org/questions/linux-software-2/how-to-show-desktop-in-xfce4-601161/#post2967109
// To build:
//   apt instal llibx11-dev
//   gcc -o toggle_desktop toggle_desktop.c -lX11
int main(int argc, char *argv[])
{
	Display *d;
	Window root;
	Atom _NET_SHOWING_DESKTOP, actual_type;
	int actual_format, error, current;
	unsigned long nitems, after;
	unsigned char *data = NULL;

	/* Open the default display */
	if(!(d = XOpenDisplay(NULL))) {
		fprintf(stderr, "Cannot open display \"%s\".\n", XDisplayName(NULL));
		exit(EXIT_FAILURE);
	}

	/* This is the default root window */
	root = DefaultRootWindow(d);

	/* find the Atom for _NET_SHOWING_DESKTOP */
	_NET_SHOWING_DESKTOP = XInternAtom(d, "_NET_SHOWING_DESKTOP", False);

	/* Obtain the current state of _NET_SHOWING_DESKTOP on the default root window */
	error = XGetWindowProperty(d, root, _NET_SHOWING_DESKTOP, 0, 1, False, XA_CARDINAL,
	                           &actual_type, &actual_format, &nitems, &after, &data);
	if(error != Success) {
		fprintf(stderr, "Received error %d!\n", error);
		XCloseDisplay(d);
		exit(EXIT_FAILURE);
	}

	/* The current state should be in data[0] */
	if(data) {
		current = data[0];
		XFree(data);
		data = NULL;
	}

	/* If nitems is 0, forget about data[0] and assume that current should be False */
	if(!nitems) {
		fprintf(stderr, "Unexpected result.\n");
		fprintf(stderr, "Assuming unshown desktop!\n");
		current = False;
	}

	/* Initialize Xevent struct */
	XEvent xev = {
		.xclient = {
			.type = ClientMessage,
			.send_event = True,
			.display = d,
			.window = root,
			.message_type = _NET_SHOWING_DESKTOP,
			.format = 32,
			.data.l[0] = !current /* That’s what we want the new state to be */
		}
	};

	/* Send the event to the window manager */
	XSendEvent(d, root, False, SubstructureRedirectMask | SubstructureNotifyMask, &xev);

	XCloseDisplay(d);
	exit(EXIT_SUCCESS);

	return 0;
}
