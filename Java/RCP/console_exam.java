public void createInitialLayout(IPageLayout layout) {  
  String editorArea = layout.getEditorArea();  
  layout.setEditorAreaVisible(false);  
  
  layout.addStandaloneView(NavigationView.ID, false, IPageLayout.LEFT,  
    0.25f, editorArea);  
  IFolderLayout folder = layout.createFolder("messages", IPageLayout.TOP,  
    0.5f, editorArea);  
  folder.addPlaceholder(View.ID + ":*");  
  folder.addView(View.ID);  
  
  IFolderLayout consoleFolder = layout.createFolder("console",  
    IPageLayout.BOTTOM, 0.65f, "messages");  
  consoleFolder.addView(IConsoleConstants.ID_CONSOLE_VIEW);  
  layout.getViewLayout(NavigationView.ID).setCloseable(false);  
 } 

///////// Action for console


public class OpenViewAction extends Action {  
      
     private final IWorkbenchWindow window;  
     private int instanceNum = 0;  
     private final String viewId;  
     MessageConsole messageConsole;  
      
     public OpenViewAction(IWorkbenchWindow window, String label, String viewId) {  
      this.window = window;  
      this.viewId = viewId;  
      setText(label);  
      // The id is used to refer to the action in a menu or toolbar  
      setId(ICommandIds.CMD_OPEN);  
      // Associate the action with a pre-defined command, to allow key  
      // bindings.  
      setActionDefinitionId(ICommandIds.CMD_OPEN);  
      setImageDescriptor(com.blog.sample.Activator  
        .getImageDescriptor("/icons/sample2.gif"));  
      
     }  
      
     public void run() {  
      if (window != null) {  
       try {  
        int instance = instanceNum++;  
        window.getActivePage().showView(viewId,  
          Integer.toString(instance),  
          IWorkbenchPage.VIEW_ACTIVATE);  
      
        messageConsole = getMessageConsole();  
        MessageConsoleStream msgConsoleStream = messageConsole  
          .newMessageStream();  
      
        ConsolePlugin.getDefault().getConsoleManager().addConsoles(  
          new IConsole[] { messageConsole });  
      
        msgConsoleStream.println(viewId + Integer.toString(instance));  
      
       } catch (PartInitException e) {  
        MessageDialog.openError(window.getShell(), "Error",  
          "Error opening view:" + e.getMessage());  
       }  
      }  
     }  
      
     private MessageConsole getMessageConsole() {  
      if (messageConsole == null) {  
       messageConsole = new MessageConsole("RCPMail", null);  
       ConsolePlugin.getDefault().getConsoleManager().addConsoles(  
         new IConsole[] { messageConsole });  
      }  
      
      return messageConsole;  
     }  
      
    }  