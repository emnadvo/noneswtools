public class MyPreferencePage extends FieldEditorPreferencePage implements IWorkbenchPreferencePage {
    public static final String PREF_USE_METRIC_UNITS = "PREF_USE_METRIC_UNITS";
    public static final String PREF_AUTO_UPDATE = "PREF_AUTO_UPDATE";
    public static final String PREF_USER_FILES_DIR = "PREF_USER_FILES_DIR";
    public static final String PREF_FAVORITE_ANIMAL = "PREF_FAVORITE_ANIMAL";

    public MyPreferencePage() {
        super(GRID);
    }

    public void createFieldEditors() {
        Composite parent = getFieldEditorParent();
        addField(new BooleanFieldEditor(PREF_USE_METRIC_UNITS, "Use &metric units", parent));
        addField(new BooleanFieldEditor(PREF_AUTO_UPDATE, "&Auto update", parent));

        addField(new DirectoryFieldEditor(PREF_USER_FILES_DIR, "User files &path:", parent));

        addField(new StringFieldEditor(PREF_FAVORITE_ANIMAL, "Favorite &animal:", parent));
    }

    public void init(IWorkbench workbench) {
        setPreferenceStore(Plugin.getPlugin().getPreferenceStore());
    }
}



public class MyPreferenceInitializer extends AbstractPreferenceInitializer {
    @Override
    public void initializeDefaultPreferences() {
        IPreferenceStore store = Plugin.getPlugin().getPreferenceStore();

        store.setDefault(MyPreferencePage.PREF_USE_METRIC_UNITS, true);
        store.setDefault(MyPreferencePage.PREF_AUTO_UPDATE, false);

        String userHome = System.getProperty("user.home");
        String defaultPath = userHome + "\\Local Settings\\Temp\\";
        store.setDefault(MyPreferencePage.PREF_USER_FILES_DIR, defaultPath);

        store.setDefault(MyPreferencePage.PREF_FAVORITE_ANIMAL, "platypus");
