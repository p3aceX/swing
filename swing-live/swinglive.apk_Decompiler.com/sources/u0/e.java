package u0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import j1.C0454D;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class e extends A0.a {
    public static final Parcelable.Creator<e> CREATOR = new C0454D(23);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f6605a;

    public e(boolean z4) {
        this.f6605a = z4;
    }

    public final boolean equals(Object obj) {
        return (obj instanceof e) && this.f6605a == ((e) obj).f6605a;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Boolean.valueOf(this.f6605a)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6605a ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
