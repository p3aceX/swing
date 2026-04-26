package E0;

import a.AbstractC0184a;
import android.os.Parcel;
import com.google.android.gms.common.internal.r;

/* JADX INFO: loaded from: classes.dex */
public final class a extends A0.a {
    public static final e CREATOR = new e();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f278a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f279b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f280c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f281d;
    public final boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f282f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final int f283m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final Class f284n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final String f285o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public h f286p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final D0.a f287q;

    public a(int i4, int i5, boolean z4, int i6, boolean z5, String str, int i7, String str2, D0.b bVar) {
        this.f278a = i4;
        this.f279b = i5;
        this.f280c = z4;
        this.f281d = i6;
        this.e = z5;
        this.f282f = str;
        this.f283m = i7;
        if (str2 == null) {
            this.f284n = null;
            this.f285o = null;
        } else {
            this.f284n = d.class;
            this.f285o = str2;
        }
        if (bVar == null) {
            this.f287q = null;
            return;
        }
        D0.a aVar = bVar.f135b;
        if (aVar == null) {
            throw new IllegalStateException("There was no converter wrapped in this ConverterWrapper.");
        }
        this.f287q = aVar;
    }

    public static a b(int i4, String str) {
        return new a(7, true, 7, true, str, i4, null);
    }

    public final String toString() {
        r rVar = new r(this);
        rVar.v(Integer.valueOf(this.f278a), "versionCode");
        rVar.v(Integer.valueOf(this.f279b), "typeIn");
        rVar.v(Boolean.valueOf(this.f280c), "typeInArray");
        rVar.v(Integer.valueOf(this.f281d), "typeOut");
        rVar.v(Boolean.valueOf(this.e), "typeOutArray");
        rVar.v(this.f282f, "outputFieldName");
        rVar.v(Integer.valueOf(this.f283m), "safeParcelFieldId");
        String str = this.f285o;
        if (str == null) {
            str = null;
        }
        rVar.v(str, "concreteTypeName");
        Class cls = this.f284n;
        if (cls != null) {
            rVar.v(cls.getCanonicalName(), "concreteType.class");
        }
        D0.a aVar = this.f287q;
        if (aVar != null) {
            rVar.v(aVar.getClass().getCanonicalName(), "converterName");
        }
        return rVar.toString();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f278a);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f279b);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f280c ? 1 : 0);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f281d);
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(this.e ? 1 : 0);
        AbstractC0184a.i0(parcel, 6, this.f282f, false);
        AbstractC0184a.o0(parcel, 7, 4);
        parcel.writeInt(this.f283m);
        D0.b bVar = null;
        String str = this.f285o;
        if (str == null) {
            str = null;
        }
        AbstractC0184a.i0(parcel, 8, str, false);
        D0.a aVar = this.f287q;
        if (aVar != null) {
            if (!(aVar instanceof D0.a)) {
                throw new IllegalArgumentException("Unsupported safe parcelable field converter class.");
            }
            bVar = new D0.b(aVar);
        }
        AbstractC0184a.h0(parcel, 9, bVar, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }

    public a(int i4, boolean z4, int i5, boolean z5, String str, int i6, Class cls) {
        this.f278a = 1;
        this.f279b = i4;
        this.f280c = z4;
        this.f281d = i5;
        this.e = z5;
        this.f282f = str;
        this.f283m = i6;
        this.f284n = cls;
        if (cls == null) {
            this.f285o = null;
        } else {
            this.f285o = cls.getCanonicalName();
        }
        this.f287q = null;
    }
}
