package P2;

import D2.AbstractActivityC0029d;
import D2.v;
import android.content.res.Configuration;
import android.os.LocaleList;
import java.util.ArrayList;
import java.util.Locale;
import y0.C0747k;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final v f1490a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final AbstractActivityC0029d f1491b;

    public a(AbstractActivityC0029d abstractActivityC0029d, v vVar) {
        C0779j c0779j = new C0779j(this, 16);
        this.f1491b = abstractActivityC0029d;
        this.f1490a = vVar;
        vVar.f261c = c0779j;
    }

    public static Locale a(String str) {
        Locale.Builder builder = new Locale.Builder();
        String[] strArrSplit = str.replace('_', '-').split("-");
        builder.setLanguage(strArrSplit[0]);
        int i4 = 1;
        if (strArrSplit.length > 1 && strArrSplit[1].length() == 4) {
            builder.setScript(strArrSplit[1]);
            i4 = 2;
        }
        if (strArrSplit.length > i4 && strArrSplit[i4].length() >= 2 && strArrSplit[i4].length() <= 3) {
            builder.setRegion(strArrSplit[i4]);
        }
        return builder.build();
    }

    public final void b(Configuration configuration) {
        ArrayList<Locale> arrayList = new ArrayList();
        LocaleList locales = configuration.getLocales();
        int size = locales.size();
        for (int i4 = 0; i4 < size; i4++) {
            arrayList.add(locales.get(i4));
        }
        v vVar = this.f1490a;
        ArrayList arrayList2 = new ArrayList();
        for (Locale locale : arrayList) {
            locale.getLanguage();
            locale.getCountry();
            locale.getVariant();
            arrayList2.add(locale.getLanguage());
            arrayList2.add(locale.getCountry());
            arrayList2.add(locale.getScript());
            arrayList2.add(locale.getVariant());
        }
        ((C0747k) vVar.f260b).O("setLocale", arrayList2, null);
    }
}
