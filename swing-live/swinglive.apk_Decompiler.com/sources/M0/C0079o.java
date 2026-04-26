package M0;

import a.AbstractC0184a;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.o, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0079o extends AbstractC0080p {
    public static final Parcelable.Creator<C0079o> CREATOR = new W(12);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final B f1030a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Uri f1031b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f1032c;

    public C0079o(B b5, Uri uri, byte[] bArr) {
        com.google.android.gms.common.internal.F.g(b5);
        this.f1030a = b5;
        com.google.android.gms.common.internal.F.g(uri);
        boolean z4 = true;
        com.google.android.gms.common.internal.F.a("origin scheme must be non-empty", uri.getScheme() != null);
        com.google.android.gms.common.internal.F.a("origin authority must be non-empty", uri.getAuthority() != null);
        this.f1031b = uri;
        if (bArr != null && bArr.length != 32) {
            z4 = false;
        }
        com.google.android.gms.common.internal.F.a("clientDataHash must be 32 bytes long", z4);
        this.f1032c = bArr;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0079o)) {
            return false;
        }
        C0079o c0079o = (C0079o) obj;
        return com.google.android.gms.common.internal.F.j(this.f1030a, c0079o.f1030a) && com.google.android.gms.common.internal.F.j(this.f1031b, c0079o.f1031b);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f1030a, this.f1031b});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 2, this.f1030a, i4, false);
        AbstractC0184a.h0(parcel, 3, this.f1031b, i4, false);
        AbstractC0184a.c0(parcel, 4, this.f1032c, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
