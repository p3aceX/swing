package N0;

import M0.W;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Base64;
import java.util.ArrayList;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class d extends A0.a {
    public static final Parcelable.Creator<d> CREATOR = new W(21);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1111a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f1112b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final f f1113c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ArrayList f1114d;

    public d(int i4, byte[] bArr, String str, ArrayList arrayList) {
        this.f1111a = i4;
        this.f1112b = bArr;
        try {
            this.f1113c = f.a(str);
            this.f1114d = arrayList;
        } catch (e e) {
            throw new IllegalArgumentException(e);
        }
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof d)) {
            return false;
        }
        d dVar = (d) obj;
        if (!Arrays.equals(this.f1112b, dVar.f1112b) || !this.f1113c.equals(dVar.f1113c)) {
            return false;
        }
        ArrayList arrayList = this.f1114d;
        ArrayList arrayList2 = dVar.f1114d;
        if (arrayList == null && arrayList2 == null) {
            return true;
        }
        return arrayList != null && arrayList2 != null && arrayList.containsAll(arrayList2) && arrayList2.containsAll(arrayList);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Integer.valueOf(Arrays.hashCode(this.f1112b)), this.f1113c, this.f1114d});
    }

    public final String toString() {
        ArrayList arrayList = this.f1114d;
        String string = arrayList == null ? "null" : arrayList.toString();
        byte[] bArr = this.f1112b;
        return "{keyHandle: " + (bArr == null ? null : Base64.encodeToString(bArr, 0)) + ", version: " + this.f1113c + ", transports: " + string + "}";
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f1111a);
        AbstractC0184a.c0(parcel, 2, this.f1112b, false);
        AbstractC0184a.i0(parcel, 3, this.f1113c.f1117a, false);
        AbstractC0184a.l0(parcel, 4, this.f1114d, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
