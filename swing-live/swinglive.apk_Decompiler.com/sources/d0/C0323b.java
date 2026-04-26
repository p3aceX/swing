package d0;

import android.os.Parcel;
import android.util.SparseIntArray;
import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: renamed from: d0.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0323b extends AbstractC0322a {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final SparseIntArray f3886d;
    public final Parcel e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f3887f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final int f3888g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final String f3889h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f3890i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public int f3891j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public int f3892k;

    public C0323b(Parcel parcel) {
        this(parcel, parcel.dataPosition(), parcel.dataSize(), "", new n.b(), new n.b(), new n.b());
    }

    @Override // d0.AbstractC0322a
    public final C0323b a() {
        Parcel parcel = this.e;
        int iDataPosition = parcel.dataPosition();
        int i4 = this.f3891j;
        if (i4 == this.f3887f) {
            i4 = this.f3888g;
        }
        return new C0323b(parcel, iDataPosition, i4, S.h(new StringBuilder(), this.f3889h, "  "), this.f3883a, this.f3884b, this.f3885c);
    }

    @Override // d0.AbstractC0322a
    public final boolean e(int i4) {
        while (this.f3891j < this.f3888g) {
            int i5 = this.f3892k;
            if (i5 == i4) {
                return true;
            }
            if (String.valueOf(i5).compareTo(String.valueOf(i4)) > 0) {
                return false;
            }
            int i6 = this.f3891j;
            Parcel parcel = this.e;
            parcel.setDataPosition(i6);
            int i7 = parcel.readInt();
            this.f3892k = parcel.readInt();
            this.f3891j += i7;
        }
        return this.f3892k == i4;
    }

    @Override // d0.AbstractC0322a
    public final void h(int i4) {
        int i5 = this.f3890i;
        SparseIntArray sparseIntArray = this.f3886d;
        Parcel parcel = this.e;
        if (i5 >= 0) {
            int i6 = sparseIntArray.get(i5);
            int iDataPosition = parcel.dataPosition();
            parcel.setDataPosition(i6);
            parcel.writeInt(iDataPosition - i6);
            parcel.setDataPosition(iDataPosition);
        }
        this.f3890i = i4;
        sparseIntArray.put(i4, parcel.dataPosition());
        parcel.writeInt(0);
        parcel.writeInt(i4);
    }

    public C0323b(Parcel parcel, int i4, int i5, String str, n.b bVar, n.b bVar2, n.b bVar3) {
        super(bVar, bVar2, bVar3);
        this.f3886d = new SparseIntArray();
        this.f3890i = -1;
        this.f3892k = -1;
        this.e = parcel;
        this.f3887f = i4;
        this.f3888g = i5;
        this.f3891j = i4;
        this.f3889h = str;
    }
}
