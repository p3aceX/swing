package P0;

import O.O;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.B;
import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public final class g extends A0.a {
    public static final Parcelable.Creator<g> CREATOR = new O(5);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1487a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0771b f1488b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final B f1489c;

    public g(int i4, C0771b c0771b, B b5) {
        this.f1487a = i4;
        this.f1488b = c0771b;
        this.f1489c = b5;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f1487a);
        AbstractC0184a.h0(parcel, 2, this.f1488b, i4, false);
        AbstractC0184a.h0(parcel, 3, this.f1489c, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
