package Y0;

import X.N;
import b1.C0243a;
import b1.C0244b;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public abstract class o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final N f2493a = new N(1);

    public static void a(C0747k c0747k) {
        R0.f fVar;
        ArrayList arrayList = new ArrayList();
        C0243a c0243a = C0243a.f3269b;
        Iterator it = ((ConcurrentHashMap) c0747k.f6831b).values().iterator();
        while (it.hasNext()) {
            for (R0.l lVar : (List) it.next()) {
                int iOrdinal = lVar.f1698d.ordinal();
                if (iOrdinal == 1) {
                    fVar = R0.f.f1683c;
                } else if (iOrdinal == 2) {
                    fVar = R0.f.f1684d;
                } else {
                    if (iOrdinal != 3) {
                        throw new IllegalStateException("Unknown key status");
                    }
                    fVar = R0.f.e;
                }
                String strSubstring = lVar.f1700g;
                if (strSubstring.startsWith("type.googleapis.com/google.crypto.")) {
                    strSubstring = strSubstring.substring(34);
                }
                arrayList.add(new C0244b(fVar, lVar.f1699f, strSubstring, lVar.e.name()));
            }
        }
        R0.l lVar2 = (R0.l) c0747k.f6832c;
        Integer numValueOf = lVar2 != null ? Integer.valueOf(lVar2.f1699f) : null;
        if (numValueOf != null) {
            try {
                int iIntValue = numValueOf.intValue();
                Iterator it2 = arrayList.iterator();
                while (it2.hasNext()) {
                    if (((C0244b) it2.next()).f3272b == iIntValue) {
                    }
                }
                throw new GeneralSecurityException("primary key ID is not present in entries");
            } catch (GeneralSecurityException e) {
                throw new IllegalStateException(e);
            }
        }
        Collections.unmodifiableList(arrayList);
    }
}
