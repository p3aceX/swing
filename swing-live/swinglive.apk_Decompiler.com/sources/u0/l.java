package u0;

import a.AbstractC0184a;
import android.app.PendingIntent;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class l extends A0.a {
    public static final Parcelable.Creator<l> CREATOR = new C0454D(27);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final PendingIntent f6623a;

    public l(PendingIntent pendingIntent) {
        F.g(pendingIntent);
        this.f6623a = pendingIntent;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof l) {
            return F.j(this.f6623a, ((l) obj).f6623a);
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f6623a});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 1, this.f6623a, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
