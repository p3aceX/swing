package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.m, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0077m extends A0.a {
    public static final Parcelable.Creator<C0077m> CREATOR = new W(10);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final EnumC0067c f1023a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Boolean f1024b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final V f1025c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final I f1026d;

    public C0077m(String str, Boolean bool, String str2, String str3) {
        EnumC0067c enumC0067cA;
        I iA = null;
        if (str == null) {
            enumC0067cA = null;
        } else {
            try {
                enumC0067cA = EnumC0067c.a(str);
            } catch (H | U | C0066b e) {
                throw new IllegalArgumentException(e);
            }
        }
        this.f1023a = enumC0067cA;
        this.f1024b = bool;
        this.f1025c = str2 == null ? null : V.a(str2);
        if (str3 != null) {
            iA = I.a(str3);
        }
        this.f1026d = iA;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0077m)) {
            return false;
        }
        C0077m c0077m = (C0077m) obj;
        return com.google.android.gms.common.internal.F.j(this.f1023a, c0077m.f1023a) && com.google.android.gms.common.internal.F.j(this.f1024b, c0077m.f1024b) && com.google.android.gms.common.internal.F.j(this.f1025c, c0077m.f1025c) && com.google.android.gms.common.internal.F.j(this.f1026d, c0077m.f1026d);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f1023a, this.f1024b, this.f1025c, this.f1026d});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        EnumC0067c enumC0067c = this.f1023a;
        AbstractC0184a.i0(parcel, 2, enumC0067c == null ? null : enumC0067c.f994a, false);
        Boolean bool = this.f1024b;
        if (bool != null) {
            AbstractC0184a.o0(parcel, 3, 4);
            parcel.writeInt(bool.booleanValue() ? 1 : 0);
        }
        V v = this.f1025c;
        AbstractC0184a.i0(parcel, 4, v == null ? null : v.f981a, false);
        I i5 = this.f1026d;
        AbstractC0184a.i0(parcel, 5, i5 != null ? i5.f966a : null, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
