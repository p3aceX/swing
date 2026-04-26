package q2;

import J3.i;
import e1.AbstractC0367g;
import java.util.ArrayList;
import java.util.List;
import n2.EnumC0559b;
import p2.C0617a;

/* JADX INFO: renamed from: q2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0635a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f6259a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final short f6260b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6261c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f6262d;
    public C0617a e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final List f6263f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public Short f6264g;

    public C0635a() {
        ArrayList arrayList = new ArrayList();
        this.f6259a = (byte) 1;
        this.f6260b = (short) 18072;
        this.f6261c = "Mpeg2TsService";
        this.f6262d = "com.pedro.srt";
        this.e = null;
        this.f6263f = arrayList;
        this.f6264g = null;
    }

    public final void a(EnumC0559b enumC0559b) {
        short s4 = AbstractC0367g.f3994b;
        if (s4 >= 8186) {
            throw new RuntimeException("Illegal pid");
        }
        AbstractC0367g.f3994b = (short) (s4 + 1);
        this.f6263f.add(new b(enumC0559b, s4));
        if (this.f6264g == null) {
            this.f6264g = Short.valueOf(s4);
        } else {
            if (enumC0559b == EnumC0559b.f5865b || enumC0559b == EnumC0559b.e) {
                return;
            }
            this.f6264g = Short.valueOf(s4);
        }
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof C0635a)) {
            return false;
        }
        C0635a c0635a = (C0635a) obj;
        return this.f6259a == c0635a.f6259a && this.f6260b == c0635a.f6260b && i.a(this.f6261c, c0635a.f6261c) && i.a(this.f6262d, c0635a.f6262d) && i.a(this.e, c0635a.e) && i.a(this.f6263f, c0635a.f6263f) && i.a(this.f6264g, c0635a.f6264g);
    }

    public final int hashCode() {
        int iHashCode = (this.f6262d.hashCode() + ((this.f6261c.hashCode() + ((Short.hashCode(this.f6260b) + (Byte.hashCode(this.f6259a) * 31)) * 31)) * 31)) * 31;
        C0617a c0617a = this.e;
        int iHashCode2 = (this.f6263f.hashCode() + ((iHashCode + (c0617a == null ? 0 : c0617a.hashCode())) * 31)) * 31;
        Short sh = this.f6264g;
        return iHashCode2 + (sh != null ? sh.hashCode() : 0);
    }

    public final String toString() {
        return "Mpeg2TsService(type=" + ((int) this.f6259a) + ", id=" + ((int) this.f6260b) + ", name=" + this.f6261c + ", providerName=" + this.f6262d + ", pmt=" + this.e + ", tracks=" + this.f6263f + ", pcrPid=" + this.f6264g + ")";
    }
}
