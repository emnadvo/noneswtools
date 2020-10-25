package org.eclipse.console.ui.views;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.part.ViewPart;

public class LightweightConsoleView extends ViewPart {
	private Text text;

	public void createPartControl(Composite parent) {
		  text = new Text(parent, SWT.READ_ONLY | SWT.MULTI);
		  OutputStream out = new OutputStream() {
		   @Override
		   public void write(int b) throws IOException {
		    if (text.isDisposed()) return;
		    text.append(String.valueOf((char) b));
	   }
	};
	final PrintStream oldOut = System.out;
	System.setOut(new PrintStream(out));
	text.addDisposeListener(new DisposeListener() {
		public void widgetDisposed(DisposeEvent e) {
			System.setOut(oldOut);
		}
	});
 }

 public void setFocus() {
  text.setFocus();
 }
}