package t0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.internal.auth.zzbz;
import j1.C0454D;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

/* JADX INFO: renamed from: t0.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0675e extends zzbz {
    public static final Parcelable.Creator<C0675e> CREATOR = new C0454D(11);

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final HashMap f6545m;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final HashSet f6546a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6547b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public f f6548c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public String f6549d;
    public String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f6550f;

    static {
        HashMap map = new HashMap();
        f6545m = map;
        map.put("authenticatorInfo", new E0.a(11, false, 11, false, "authenticatorInfo", 2, f.class));
        map.put("signature", new E0.a(7, false, 7, false, "signature", 3, null));
        map.put("package", new E0.a(7, false, 7, false, "package", 4, null));
    }

    public C0675e(HashSet hashSet, int i4, f fVar, String str, String str2, String str3) {
        this.f6546a = hashSet;
        this.f6547b = i4;
        this.f6548c = fVar;
        this.f6549d = str;
        this.e = str2;
        this.f6550f = str3;
    }

    @Override // E0.b
    public final void addConcreteTypeInternal(E0.a aVar, String str, E0.b bVar) {
        int i4 = aVar.f283m;
        if (i4 != 2) {
            throw new IllegalArgumentException(String.format("Field with id=%d is not a known custom type. Found %s", Integer.valueOf(i4), bVar.getClass().getCanonicalName()));
        }
        this.f6548c = (f) bVar;
        this.f6546a.add(Integer.valueOf(i4));
    }

    @Override // E0.b
    public final /* synthetic */ Map getFieldMappings() {
        return f6545m;
    }

    @Override // E0.b
    public final Object getFieldValue(E0.a aVar) {
        int i4 = aVar.f283m;
        if (i4 == 1) {
            return Integer.valueOf(this.f6547b);
        }
        if (i4 == 2) {
            return this.f6548c;
        }
        if (i4 == 3) {
            return this.f6549d;
        }
        if (i4 == 4) {
            return this.e;
        }
        throw new IllegalStateException("Unknown SafeParcelable id=" + aVar.f283m);
    }

    @Override // E0.b
    public final boolean isFieldSet(E0.a aVar) {
        return this.f6546a.contains(Integer.valueOf(aVar.f283m));
    }

    @Override // E0.b
    public final void setStringInternal(E0.a aVar, String str, String str2) {
        int i4 = aVar.f283m;
        if (i4 == 3) {
            this.f6549d = str2;
        } else {
            if (i4 != 4) {
                throw new IllegalArgumentException(String.format("Field with id=%d is not known to be a string.", Integer.valueOf(i4)));
            }
            this.e = str2;
        }
        this.f6546a.add(Integer.valueOf(i4));
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        HashSet hashSet = this.f6546a;
        if (hashSet.contains(1)) {
            AbstractC0184a.o0(parcel, 1, 4);
            parcel.writeInt(this.f6547b);
        }
        if (hashSet.contains(2)) {
            AbstractC0184a.h0(parcel, 2, this.f6548c, i4, true);
        }
        if (hashSet.contains(3)) {
            AbstractC0184a.i0(parcel, 3, this.f6549d, true);
        }
        if (hashSet.contains(4)) {
            AbstractC0184a.i0(parcel, 4, this.e, true);
        }
        if (hashSet.contains(5)) {
            AbstractC0184a.i0(parcel, 5, this.f6550f, true);
        }
        AbstractC0184a.n0(iM0, parcel);
    }
}
