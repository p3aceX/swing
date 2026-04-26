package w;

import android.content.res.Configuration;
import android.os.LocaleList;

/* JADX INFO: renamed from: w.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0698a {
    public static LocaleList a(Configuration configuration) {
        return configuration.getLocales();
    }

    public static void b(Configuration configuration, d dVar) {
        configuration.setLocales(dVar.f6680a.f6681a);
    }
}
