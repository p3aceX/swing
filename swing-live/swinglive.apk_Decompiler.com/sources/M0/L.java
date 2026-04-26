package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.internal.fido.zzal;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class L extends A0.a {
    public static final Parcelable.Creator<L> CREATOR = new D0.c(26);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final J f969a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f970b;

    static {
        new L("supported", null);
        new L("not-supported", null);
    }

    public L(String str, String str2) {
        com.google.android.gms.common.internal.F.g(str);
        try {
            this.f969a = J.a(str);
            this.f970b = str2;
        } catch (K e) {
            throw new IllegalArgumentException(e);
        }
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof L)) {
            return false;
        }
        L l2 = (L) obj;
        return zzal.zza(this.f969a, l2.f969a) && zzal.zza(this.f970b, l2.f970b);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f969a, this.f970b});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 2, this.f969a.f968a, false);
        AbstractC0184a.i0(parcel, 3, this.f970b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
