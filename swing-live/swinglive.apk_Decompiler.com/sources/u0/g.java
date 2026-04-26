package u0;

import a.AbstractC0184a;
import android.app.PendingIntent;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;

/* JADX INFO: loaded from: classes.dex */
public final class g extends A0.a {
    public static final Parcelable.Creator<g> CREATOR = new C0454D(17);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final PendingIntent f6612a;

    public g(PendingIntent pendingIntent) {
        F.g(pendingIntent);
        this.f6612a = pendingIntent;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 1, this.f6612a, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
