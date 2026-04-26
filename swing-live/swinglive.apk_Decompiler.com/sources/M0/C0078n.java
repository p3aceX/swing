package M0;

import a.AbstractC0184a;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0078n extends AbstractC0080p {
    public static final Parcelable.Creator<C0078n> CREATOR = new W(11);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0088y f1027a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Uri f1028b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f1029c;

    public C0078n(C0088y c0088y, Uri uri, byte[] bArr) {
        com.google.android.gms.common.internal.F.g(c0088y);
        this.f1027a = c0088y;
        com.google.android.gms.common.internal.F.g(uri);
        boolean z4 = true;
        com.google.android.gms.common.internal.F.a("origin scheme must be non-empty", uri.getScheme() != null);
        com.google.android.gms.common.internal.F.a("origin authority must be non-empty", uri.getAuthority() != null);
        this.f1028b = uri;
        if (bArr != null && bArr.length != 32) {
            z4 = false;
        }
        com.google.android.gms.common.internal.F.a("clientDataHash must be 32 bytes long", z4);
        this.f1029c = bArr;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0078n)) {
            return false;
        }
        C0078n c0078n = (C0078n) obj;
        return com.google.android.gms.common.internal.F.j(this.f1027a, c0078n.f1027a) && com.google.android.gms.common.internal.F.j(this.f1028b, c0078n.f1028b);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f1027a, this.f1028b});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 2, this.f1027a, i4, false);
        AbstractC0184a.h0(parcel, 3, this.f1028b, i4, false);
        AbstractC0184a.c0(parcel, 4, this.f1029c, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
