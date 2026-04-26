package t0;

import a.AbstractC0184a;
import android.app.PendingIntent;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.internal.auth.zzbz;
import j1.C0454D;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class f extends zzbz {
    public static final Parcelable.Creator<f> CREATOR = new C0454D(12);

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final HashMap f6551n;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final HashSet f6552a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6553b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public String f6554c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f6555d;
    public byte[] e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final PendingIntent f6556f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final C0671a f6557m;

    static {
        HashMap map = new HashMap();
        f6551n = map;
        map.put("accountType", new E0.a(7, false, 7, false, "accountType", 2, null));
        map.put("status", new E0.a(0, false, 0, false, "status", 3, null));
        map.put("transferBytes", new E0.a(8, false, 8, false, "transferBytes", 4, null));
    }

    public f(HashSet hashSet, int i4, String str, int i5, byte[] bArr, PendingIntent pendingIntent, C0671a c0671a) {
        this.f6552a = hashSet;
        this.f6553b = i4;
        this.f6554c = str;
        this.f6555d = i5;
        this.e = bArr;
        this.f6556f = pendingIntent;
        this.f6557m = c0671a;
    }

    @Override // E0.b
    public final /* synthetic */ Map getFieldMappings() {
        return f6551n;
    }

    @Override // E0.b
    public final Object getFieldValue(E0.a aVar) {
        int i4 = aVar.f283m;
        if (i4 == 1) {
            return Integer.valueOf(this.f6553b);
        }
        if (i4 == 2) {
            return this.f6554c;
        }
        if (i4 == 3) {
            return Integer.valueOf(this.f6555d);
        }
        if (i4 == 4) {
            return this.e;
        }
        throw new IllegalStateException("Unknown SafeParcelable id=" + aVar.f283m);
    }

    @Override // E0.b
    public final boolean isFieldSet(E0.a aVar) {
        return this.f6552a.contains(Integer.valueOf(aVar.f283m));
    }

    @Override // E0.b
    public final void setDecodedBytesInternal(E0.a aVar, String str, byte[] bArr) {
        int i4 = aVar.f283m;
        if (i4 != 4) {
            throw new IllegalArgumentException(B1.a.l("Field with id=", i4, " is not known to be a byte array."));
        }
        this.e = bArr;
        this.f6552a.add(Integer.valueOf(i4));
    }

    @Override // E0.b
    public final void setIntegerInternal(E0.a aVar, String str, int i4) {
        int i5 = aVar.f283m;
        if (i5 != 3) {
            throw new IllegalArgumentException(B1.a.l("Field with id=", i5, " is not known to be an int."));
        }
        this.f6555d = i4;
        this.f6552a.add(Integer.valueOf(i5));
    }

    @Override // E0.b
    public final void setStringInternal(E0.a aVar, String str, String str2) {
        int i4 = aVar.f283m;
        if (i4 != 2) {
            throw new IllegalArgumentException(String.format("Field with id=%d is not known to be a string.", Integer.valueOf(i4)));
        }
        this.f6554c = str2;
        this.f6552a.add(Integer.valueOf(i4));
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        HashSet hashSet = this.f6552a;
        if (hashSet.contains(1)) {
            AbstractC0184a.o0(parcel, 1, 4);
            parcel.writeInt(this.f6553b);
        }
        if (hashSet.contains(2)) {
            AbstractC0184a.i0(parcel, 2, this.f6554c, true);
        }
        if (hashSet.contains(3)) {
            int i5 = this.f6555d;
            AbstractC0184a.o0(parcel, 3, 4);
            parcel.writeInt(i5);
        }
        if (hashSet.contains(4)) {
            AbstractC0184a.c0(parcel, 4, this.e, true);
        }
        if (hashSet.contains(5)) {
            AbstractC0184a.h0(parcel, 5, this.f6556f, i4, true);
        }
        if (hashSet.contains(6)) {
            AbstractC0184a.h0(parcel, 6, this.f6557m, i4, true);
        }
        AbstractC0184a.n0(iM0, parcel);
    }
}
