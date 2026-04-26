package u0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class c extends A0.a {
    public static final Parcelable.Creator<c> CREATOR = new C0454D(21);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f6600a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6601b;

    public c(String str, boolean z4) {
        if (z4) {
            F.g(str);
        }
        this.f6600a = z4;
        this.f6601b = str;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof c)) {
            return false;
        }
        c cVar = (c) obj;
        return this.f6600a == cVar.f6600a && F.j(this.f6601b, cVar.f6601b);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Boolean.valueOf(this.f6600a), this.f6601b});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6600a ? 1 : 0);
        AbstractC0184a.i0(parcel, 2, this.f6601b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
