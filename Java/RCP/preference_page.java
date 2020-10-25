import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferencePage;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.DirectoryDialog;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.core.runtime.Platform;

	@Override
	protected Control createContents(Composite parent) {
		Composite top = new Composite(parent, SWT.NONE);
		// TODO Auto-generated method stub

		// Sets the layout data for the top composite's 
		// place in its parent's layout.
		GridData grdData = new GridData(GridData.HORIZONTAL_ALIGN_FILL,
										GridData.VERTICAL_ALIGN_BEGINNING, true, false);
		grdData.horizontalSpan = 3;
		top.setLayoutData(grdData);
		
		// Sets the layout for the top composite's 
		// children to populate.
		GridLayout grlayout = new GridLayout();
		grlayout.numColumns = 3;
		grlayout.makeColumnsEqualWidth = false;
		grlayout.verticalSpacing = 10;
		top.setLayout(grlayout);
		
		Label defProjLabel = new Label(top, SWT.NONE);
		defProjLabel.setText("Default project &path");
		
		final Text defProjPath = new Text(top, SWT.LEFT | SWT.SINGLE | SWT.BORDER);
		GridData gd = new GridData(SWT.FILL, SWT.TOP, true, false, 1, 1);
		gd.horizontalIndent = 5;
		defProjPath.setLayoutData(gd);
		
		String currPath = Platform.getLocation().toString();
		defProjPath.setText(currPath);
		
		Button cwdBtn = new Button(top, SWT.PUSH | SWT.RIGHT);
		cwdBtn.setText("Browse...");
		
		GridData btnGrData = new GridData();
		btnGrData.horizontalAlignment = GridData.FILL;
		cwdBtn.setLayoutData(btnGrData);
		//Method for click and release btn
		cwdBtn.addSelectionListener(new SelectionListener() {
			
			@Override
			public void widgetSelected(SelectionEvent e) {
				// TODO Auto-generated method stub
				DirectoryDialog dirDlg = new DirectoryDialog(getShell(), SWT.NONE);
				dirDlg.setFilterPath(defProjPath.getText());
				
				String resVal = dirDlg.open();
				if (!resVal.isEmpty())
				{
					defProjPath.setText(resVal);
				}
			}
			
			@Override
			public void widgetDefaultSelected(SelectionEvent e) {
				// TODO Auto-generated method stub
				this.widgetSelected(e);
			}
		});
		
		return top;
	}
