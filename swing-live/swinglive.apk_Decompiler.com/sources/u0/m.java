package u0;

import M0.C0087x;
import a.AbstractC0184a;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class m extends A0.a {
    public static final Parcelable.Creator<m> CREATOR = new C0454D(28);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6624a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6625b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6626c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f6627d;
    public final Uri e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f6628f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final String f6629m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final String f6630n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final C0087x f6631o;

    public m(String str, String str2, String str3, String str4, Uri uri, String str5, String str6, String str7, C0087x c0087x) {
        F.g(str);
        this.f6624a = str;
        this.f6625b = str2;
        this.f6626c = str3;
        this.f6627d = str4;
        this.e = uri;
        this.f6628f = str5;
        this.f6629m = str6;
        this.f6630n = str7;
        this.f6631o = c0087x;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof m)) {
            return false;
        }
        m mVar = (m) obj;
        return F.j(this.f6624a, mVar.f6624a) && F.j(this.f6625b, mVar.f6625b) && F.j(this.f6626c, mVar.f6626c) && F.j(this.f6627d, mVar.f6627d) && F.j(this.e, mVar.e) && F.j(this.f6628f, mVar.f6628f) && F.j(this.f6629m, mVar.f6629m) && F.j(this.f6630n, mVar.f6630n) && F.j(this.f6631o, mVar.f6631o);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f6624a, this.f6625b, this.f6626c, this.f6627d, this.e, this.f6628f, this.f6629m, this.f6630n, this.f6631o});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f6624a, false);
        AbstractC0184a.i0(parcel, 2, this.f6625b, false);
        AbstractC0184a.i0(parcel, 3, this.f6626c, false);
        AbstractC0184a.i0(parcel, 4, this.f6627d, false);
        AbstractC0184a.h0(parcel, 5, this.e, i4, false);
        AbstractC0184a.i0(parcel, 6, this.f6628f, false);
        AbstractC0184a.i0(parcel, 7, this.f6629m, false);
        AbstractC0184a.i0(parcel, 8, this.f6630n, false);
        AbstractC0184a.h0(parcel, 9, this.f6631o, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
