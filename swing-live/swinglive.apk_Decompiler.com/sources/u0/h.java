package u0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class h extends A0.a {
    public static final Parcelable.Creator<h> CREATOR = new C0454D(18);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6613a;

    public h(int i4) {
        this.f6613a = i4;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof h) {
            return F.j(Integer.valueOf(this.f6613a), Integer.valueOf(((h) obj).f6613a));
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Integer.valueOf(this.f6613a)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6613a);
        AbstractC0184a.n0(iM0, parcel);
    }
}
