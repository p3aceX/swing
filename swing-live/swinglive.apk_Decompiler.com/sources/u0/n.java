package u0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class n extends A0.a {
    public static final Parcelable.Creator<n> CREATOR = new C0454D(29);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6632a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6633b;

    public n(String str, String str2) {
        F.h(str, "Account identifier cannot be null");
        String strTrim = str.trim();
        F.e(strTrim, "Account identifier cannot be empty");
        this.f6632a = strTrim;
        F.d(str2);
        this.f6633b = str2;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof n)) {
            return false;
        }
        n nVar = (n) obj;
        return F.j(this.f6632a, nVar.f6632a) && F.j(this.f6633b, nVar.f6633b);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f6632a, this.f6633b});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f6632a, false);
        AbstractC0184a.i0(parcel, 2, this.f6633b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
