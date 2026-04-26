package P0;

import O.O;
import a.AbstractC0184a;
import android.content.Intent;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.s;

/* JADX INFO: loaded from: classes.dex */
public final class b extends A0.a implements s {
    public static final Parcelable.Creator<b> CREATOR = new O(2);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1480a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f1481b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Intent f1482c;

    public b(int i4, int i5, Intent intent) {
        this.f1480a = i4;
        this.f1481b = i5;
        this.f1482c = intent;
    }

    @Override // com.google.android.gms.common.api.s
    public final Status getStatus() {
        return this.f1481b == 0 ? Status.f3372f : Status.f3376p;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f1480a);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f1481b);
        AbstractC0184a.h0(parcel, 3, this.f1482c, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
