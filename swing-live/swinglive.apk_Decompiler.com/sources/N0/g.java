package N0;

import M0.W;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class g extends A0.a {
    public static final Parcelable.Creator<g> CREATOR = new W(23);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1118a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final f f1119b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f1120c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f1121d;

    public g(int i4, String str, byte[] bArr, String str2) {
        this.f1118a = i4;
        try {
            this.f1119b = f.a(str);
            this.f1120c = bArr;
            this.f1121d = str2;
        } catch (e e) {
            throw new IllegalArgumentException(e);
        }
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof g)) {
            return false;
        }
        g gVar = (g) obj;
        if (!Arrays.equals(this.f1120c, gVar.f1120c) || this.f1119b != gVar.f1119b) {
            return false;
        }
        String str = gVar.f1121d;
        String str2 = this.f1121d;
        if (str2 == null) {
            if (str != null) {
                return false;
            }
        } else if (!str2.equals(str)) {
            return false;
        }
        return true;
    }

    public final int hashCode() {
        int iHashCode = ((Arrays.hashCode(this.f1120c) + 31) * 31) + this.f1119b.hashCode();
        String str = this.f1121d;
        return (iHashCode * 31) + (str == null ? 0 : str.hashCode());
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f1118a);
        AbstractC0184a.i0(parcel, 2, this.f1119b.f1117a, false);
        AbstractC0184a.c0(parcel, 3, this.f1120c, false);
        AbstractC0184a.i0(parcel, 4, this.f1121d, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
