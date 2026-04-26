package u0;

import a.AbstractC0184a;
import android.app.PendingIntent;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.ArrayList;
import java.util.Arrays;

/* JADX INFO: renamed from: u0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0687a extends A0.a {
    public static final Parcelable.Creator<C0687a> CREATOR = new C0454D(15);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6589a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6590b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6591c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ArrayList f6592d;
    public final GoogleSignInAccount e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final PendingIntent f6593f;

    public C0687a(String str, String str2, String str3, ArrayList arrayList, GoogleSignInAccount googleSignInAccount, PendingIntent pendingIntent) {
        this.f6589a = str;
        this.f6590b = str2;
        this.f6591c = str3;
        F.g(arrayList);
        this.f6592d = arrayList;
        this.f6593f = pendingIntent;
        this.e = googleSignInAccount;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0687a)) {
            return false;
        }
        C0687a c0687a = (C0687a) obj;
        return F.j(this.f6589a, c0687a.f6589a) && F.j(this.f6590b, c0687a.f6590b) && F.j(this.f6591c, c0687a.f6591c) && F.j(this.f6592d, c0687a.f6592d) && F.j(this.f6593f, c0687a.f6593f) && F.j(this.e, c0687a.e);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f6589a, this.f6590b, this.f6591c, this.f6592d, this.f6593f, this.e});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f6589a, false);
        AbstractC0184a.i0(parcel, 2, this.f6590b, false);
        AbstractC0184a.i0(parcel, 3, this.f6591c, false);
        AbstractC0184a.j0(parcel, 4, this.f6592d);
        AbstractC0184a.h0(parcel, 5, this.e, i4, false);
        AbstractC0184a.h0(parcel, 6, this.f6593f, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
