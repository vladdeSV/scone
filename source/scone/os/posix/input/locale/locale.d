module scone.os.posix.input.locale.locale;

version (Posix)
{
    class Locale
    {
        //todo: figure out if can get information about locale from terminal session?

        string systemLocaleSequences()
        {
            version (OSX)
            {
                return import("osx.sv_se.tsv");
            }
            else
            {
                //fallback
                return import("ubuntu.sv_se.tsv");
            }
        }
    }
}
