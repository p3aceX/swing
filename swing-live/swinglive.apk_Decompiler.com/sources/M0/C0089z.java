package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.internal.fido.zzau;
import com.google.android.gms.internal.fido.zzh;
import java.util.ArrayList;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.z, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0089z extends A0.a {
    public static final Parcelable.Creator<C0089z> CREATOR;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final E f1057a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f1058b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ArrayList f1059c;

    static {
        zzau.zzi(zzh.zza, zzh.zzb);
        CREATOR = new D0.c(18);
    }

    public C0089z(String str, byte[] bArr, ArrayList arrayList) {
        com.google.android.gms.common.internal.F.g(str);
        try {
            this.f1057a = E.a(str);
            com.google.android.gms.common.internal.F.g(bArr);
            this.f1058b = bArr;
            this.f1059c = arrayList;
        } catch (D e) {
            throw new IllegalArgumentException(e);
        }
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0089z)) {
            return false;
        }
        C0089z c0089z = (C0089z) obj;
        if (!this.f1057a.equals(c0089z.f1057a) || !Arrays.equals(this.f1058b, c0089z.f1058b)) {
            return false;
        }
        ArrayList arrayList = this.f1059c;
        ArrayList arrayList2 = c0089z.f1059c;
        if (arrayList == null && arrayList2 == null) {
            return true;
        }
        return arrayList != null && arrayList2 != null && arrayList.containsAll(arrayList2) && arrayList2.containsAll(arrayList);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f1057a, Integer.valueOf(Arrays.hashCode(this.f1058b)), this.f1059c});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        this.f1057a.getClass();
        AbstractC0184a.i0(parcel, 2, "public-key", false);
        AbstractC0184a.c0(parcel, 3, this.f1058b, false);
        AbstractC0184a.l0(parcel, 4, this.f1059c, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
