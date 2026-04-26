package q3;

import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Iterator;
import java.util.List;
import o3.C0590F;
import o3.C0592H;
import o3.C0599g;
import x3.AbstractC0729i;

/* JADX INFO: renamed from: q3.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0643h {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final List f6297a;

    static {
        EnumC0636a enumC0636a = EnumC0636a.f6269m;
        EnumC0642g enumC0642g = EnumC0642g.f6294d;
        C0599g c0599g = C0599g.f6092b;
        C0637b c0637b = new C0637b(enumC0636a, enumC0642g, C0599g.f6092b);
        EnumC0636a enumC0636a2 = EnumC0636a.f6268f;
        C0637b c0637b2 = new C0637b(enumC0636a2, enumC0642g, C0599g.f6093c);
        EnumC0636a enumC0636a3 = EnumC0636a.f6270n;
        EnumC0642g enumC0642g2 = EnumC0642g.f6293c;
        f6297a = AbstractC0729i.T(c0637b, c0637b2, new C0637b(enumC0636a3, enumC0642g2, C0599g.f6094d), new C0637b(enumC0636a, enumC0642g2, C0599g.e), new C0637b(enumC0636a2, enumC0642g2, C0599g.f6095f), new C0637b(EnumC0636a.e, enumC0642g2, C0599g.f6096g));
    }

    public static final C0637b a(byte b5, byte b6) throws C0590F {
        Object next;
        Object next2;
        Object next3;
        C0592H c0592h = EnumC0642g.f6292b;
        if (b6 == 0) {
            throw new IllegalStateException("Anonymous signature not allowed.");
        }
        Iterator it = f6297a.iterator();
        while (true) {
            if (!it.hasNext()) {
                next = null;
                break;
            }
            next = it.next();
            C0637b c0637b = (C0637b) next;
            if (c0637b.f6276a.f6273a == b5 && c0637b.f6277b.f6296a == b6) {
                break;
            }
        }
        C0637b c0637b2 = (C0637b) next;
        if (c0637b2 != null) {
            return c0637b2;
        }
        EnumC0636a.f6267d.getClass();
        Iterator it2 = EnumC0636a.f6272p.iterator();
        while (true) {
            if (!it2.hasNext()) {
                next2 = null;
                break;
            }
            next2 = it2.next();
            if (((EnumC0636a) next2).f6273a == b5) {
                break;
            }
        }
        EnumC0636a enumC0636a = (EnumC0636a) next2;
        if (enumC0636a == null) {
            throw new C0590F(S.d(b5, "Unknown hash algorithm: "), 0);
        }
        EnumC0642g.f6292b.getClass();
        Iterator it3 = EnumC0642g.f6295f.iterator();
        while (true) {
            if (!it3.hasNext()) {
                next3 = null;
                break;
            }
            next3 = it3.next();
            if (((EnumC0642g) next3).f6296a == b6) {
                break;
            }
        }
        EnumC0642g enumC0642g = (EnumC0642g) next3;
        if (enumC0642g == null) {
            return null;
        }
        return new C0637b(enumC0636a, enumC0642g, null);
    }
}
