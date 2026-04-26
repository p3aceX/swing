package t0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.internal.auth.zzbz;
import j1.C0454D;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

/* JADX INFO: renamed from: t0.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0672b extends zzbz {
    public static final Parcelable.Creator<C0672b> CREATOR = new C0454D(9);

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final HashMap f6534f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final HashSet f6535a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6536b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public ArrayList f6537c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f6538d;
    public C0674d e;

    static {
        HashMap map = new HashMap();
        f6534f = map;
        map.put("authenticatorData", new E0.a(11, true, 11, true, "authenticatorData", 2, C0675e.class));
        map.put("progress", new E0.a(11, false, 11, false, "progress", 4, C0674d.class));
    }

    public C0672b(HashSet hashSet, int i4, ArrayList arrayList, int i5, C0674d c0674d) {
        this.f6535a = hashSet;
        this.f6536b = i4;
        this.f6537c = arrayList;
        this.f6538d = i5;
        this.e = c0674d;
    }

    @Override // E0.b
    public final void addConcreteTypeArrayInternal(E0.a aVar, String str, ArrayList arrayList) {
        int i4 = aVar.f283m;
        if (i4 != 2) {
            throw new IllegalArgumentException(String.format("Field with id=%d is not a known ConcreteTypeArray type. Found %s", Integer.valueOf(i4), arrayList.getClass().getCanonicalName()));
        }
        this.f6537c = arrayList;
        this.f6535a.add(Integer.valueOf(i4));
    }

    @Override // E0.b
    public final void addConcreteTypeInternal(E0.a aVar, String str, E0.b bVar) {
        int i4 = aVar.f283m;
        if (i4 != 4) {
            throw new IllegalArgumentException(String.format("Field with id=%d is not a known custom type. Found %s", Integer.valueOf(i4), bVar.getClass().getCanonicalName()));
        }
        this.e = (C0674d) bVar;
        this.f6535a.add(Integer.valueOf(i4));
    }

    @Override // E0.b
    public final /* synthetic */ Map getFieldMappings() {
        return f6534f;
    }

    @Override // E0.b
    public final Object getFieldValue(E0.a aVar) {
        int i4 = aVar.f283m;
        if (i4 == 1) {
            return Integer.valueOf(this.f6536b);
        }
        if (i4 == 2) {
            return this.f6537c;
        }
        if (i4 == 4) {
            return this.e;
        }
        throw new IllegalStateException("Unknown SafeParcelable id=" + aVar.f283m);
    }

    @Override // E0.b
    public final boolean isFieldSet(E0.a aVar) {
        return this.f6535a.contains(Integer.valueOf(aVar.f283m));
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        HashSet hashSet = this.f6535a;
        if (hashSet.contains(1)) {
            AbstractC0184a.o0(parcel, 1, 4);
            parcel.writeInt(this.f6536b);
        }
        if (hashSet.contains(2)) {
            AbstractC0184a.l0(parcel, 2, this.f6537c, true);
        }
        if (hashSet.contains(3)) {
            AbstractC0184a.o0(parcel, 3, 4);
            parcel.writeInt(this.f6538d);
        }
        if (hashSet.contains(4)) {
            AbstractC0184a.h0(parcel, 4, this.e, i4, true);
        }
        AbstractC0184a.n0(iM0, parcel);
    }
}
