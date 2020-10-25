   /**
     * Reroute default output streams to a new console, added to console view.
     */
    public static void linkDefaultOutStreamToConsole() {
        // Create a msg console
        final MessageConsole console = new MessageConsole("Console", null);

        // Add it to console manager
        ConsolePlugin.getDefault().getConsoleManager().addConsoles(new IConsole[] {vConsole });

        PrintStream printStream = new PrintStream(console.newMessageStream());

        // Link standard output stream to the console
        System.setOut(printStream);

        // Link error output stream to the console
        System.setErr(printStream);

    }

    /**
     * Reset output stream to system ones.
     */
    public static void unlinkDefaultOutStreamToConsole() {

        System.setOut(System.out);
        System.setErr(System.err);
    }
