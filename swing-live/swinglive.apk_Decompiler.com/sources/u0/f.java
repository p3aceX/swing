package u0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class f extends A0.a {
    public static final Parcelable.Creator<f> CREATOR = new C0454D(16);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final e f6606a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final b f6607b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6608c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f6609d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final d f6610f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final c f6611m;

    public f(e eVar, b bVar, String str, boolean z4, int i4, d dVar, c cVar) {
        F.g(eVar);
        this.f6606a = eVar;
        F.g(bVar);
        this.f6607b = bVar;
        this.f6608c = str;
        this.f6609d = z4;
        this.e = i4;
        this.f6610f = dVar == null ? new d(null, false, null) : dVar;
        this.f6611m = cVar == null ? new c(null, false) : cVar;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof f)) {
            return false;
        }
        f fVar = (f) obj;
        return F.j(this.f6606a, fVar.f6606a) && F.j(this.f6607b, fVar.f6607b) && F.j(this.f6610f, fVar.f6610f) && F.j(this.f6611m, fVar.f6611m) && F.j(this.f6608c, fVar.f6608c) && this.f6609d == fVar.f6609d && this.e == fVar.e;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f6606a, this.f6607b, this.f6610f, this.f6611m, this.f6608c, Boolean.valueOf(this.f6609d)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 1, this.f6606a, i4, false);
        AbstractC0184a.h0(parcel, 2, this.f6607b, i4, false);
        AbstractC0184a.i0(parcel, 3, this.f6608c, false);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f6609d ? 1 : 0);
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(this.e);
        AbstractC0184a.h0(parcel, 6, this.f6610f, i4, false);
        AbstractC0184a.h0(parcel, 7, this.f6611m, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
