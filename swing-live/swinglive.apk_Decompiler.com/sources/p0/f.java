package P0;

import O.O;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.A;

/* JADX INFO: loaded from: classes.dex */
public final class f extends A0.a {
    public static final Parcelable.Creator<f> CREATOR = new O(4);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1485a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final A f1486b;

    public f(int i4, A a5) {
        this.f1485a = i4;
        this.f1486b = a5;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f1485a);
        AbstractC0184a.h0(parcel, 2, this.f1486b, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
