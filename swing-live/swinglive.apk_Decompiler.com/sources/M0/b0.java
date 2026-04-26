package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class b0 extends A0.a {
    public static final Parcelable.Creator<b0> CREATOR = new W(16);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f992a;

    public b0(boolean z4) {
        this.f992a = Boolean.valueOf(z4).booleanValue();
    }

    public final boolean equals(Object obj) {
        return (obj instanceof b0) && this.f992a == ((b0) obj).f992a;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Boolean.valueOf(this.f992a)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f992a ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
