package o3;

import java.util.ArrayList;
import java.util.List;
import q3.EnumC0636a;
import q3.EnumC0642g;
import r3.AbstractC0656b;
import r3.C0655a;
import x3.AbstractC0729i;

/* JADX INFO: renamed from: o3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0593a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final ArrayList f6065a;

    static {
        EnumC0604l enumC0604l = EnumC0604l.f6114c;
        EnumC0636a enumC0636a = EnumC0636a.f6268f;
        EnumC0642g enumC0642g = EnumC0642g.f6293c;
        C0594b c0594b = new C0594b((short) 156, "TLS_RSA_WITH_AES_128_GCM_SHA256", "AES128-GCM-SHA256", enumC0604l, 128, enumC0636a, enumC0642g);
        EnumC0604l enumC0604l2 = EnumC0604l.f6113b;
        EnumC0636a enumC0636a2 = EnumC0636a.f6269m;
        EnumC0642g enumC0642g2 = EnumC0642g.f6294d;
        C0594b c0594b2 = new C0594b((short) -16340, "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "ECDHE-ECDSA-AES256-GCM-SHA384", enumC0604l2, 256, enumC0636a2, enumC0642g2);
        C0594b c0594b3 = new C0594b((short) -16341, "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "ECDHE-ECDSA-AES128-GCM-SHA256", enumC0604l2, 128, enumC0636a, enumC0642g2);
        C0594b c0594b4 = new C0594b((short) -16336, "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", "ECDHE-RSA-AES256-GCM-SHA384", enumC0604l2, 256, enumC0636a2, enumC0642g);
        C0594b c0594b5 = new C0594b((short) -16337, "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "ECDHE-RSA-AES128-GCM-SHA256", enumC0604l2, 128, enumC0636a, enumC0642g);
        EnumC0595c enumC0595c = EnumC0595c.f6082b;
        List listT = AbstractC0729i.T(c0594b2, c0594b4, c0594b3, c0594b5, c0594b, new C0594b((short) 53, "TLS_RSA_WITH_AES_256_CBC_SHA", "AES-256-CBC-SHA", enumC0604l, "AES/CBC/NoPadding", 256, 16, 48, 20, "HmacSHA1", 160, enumC0636a, enumC0642g, enumC0595c), new C0594b((short) 47, "TLS_RSA_WITH_AES_128_CBC_SHA", "AES-128-CBC-SHA", enumC0604l, "AES/CBC/NoPadding", 128, 16, 48, 20, "HmacSHA1", 160, enumC0636a, enumC0642g, enumC0595c));
        ArrayList arrayList = new ArrayList();
        for (Object obj : listT) {
            C0594b c0594b6 = (C0594b) obj;
            J3.i.e(c0594b6, "<this>");
            w3.f fVar = AbstractC0656b.f6432a;
            String str = ((C0655a) fVar.a()).f6430a;
            int iHashCode = str.hashCode();
            int i4 = c0594b6.f6070f;
            if (iHashCode != 46676283) {
                if (iHashCode != 46677244) {
                    if (iHashCode != 46678205 || !str.equals("1.8.0") || ((C0655a) fVar.a()).f6431b >= 161 || i4 <= 128) {
                        arrayList.add(obj);
                    }
                } else if (!str.equals("1.7.0") || ((C0655a) fVar.a()).f6431b >= 171 || i4 <= 128) {
                    arrayList.add(obj);
                }
            } else if (!str.equals("1.6.0") || ((C0655a) fVar.a()).f6431b >= 181 || i4 <= 128) {
                arrayList.add(obj);
            }
        }
        f6065a = arrayList;
    }
}
