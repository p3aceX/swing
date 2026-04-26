package k1;

import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.internal.p002firebaseauthapi.zzafm;
import com.google.android.gms.internal.p002firebaseauthapi.zzafp;
import j1.C0455E;
import java.util.ArrayList;

/* JADX INFO: renamed from: k1.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0511b implements Parcelable.Creator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5504a;

    public /* synthetic */ C0511b(int i4) {
        this.f5504a = i4;
    }

    @Override // android.os.Parcelable.Creator
    public final Object createFromParcel(Parcel parcel) {
        switch (this.f5504a) {
            case 0:
                int iI0 = H0.a.i0(parcel);
                String strQ = null;
                String strQ2 = null;
                String strQ3 = null;
                String strQ4 = null;
                String strQ5 = null;
                String strQ6 = null;
                String strQ7 = null;
                boolean zS = false;
                while (parcel.dataPosition() < iI0) {
                    int i4 = parcel.readInt();
                    switch ((char) i4) {
                        case 1:
                            strQ = H0.a.q(i4, parcel);
                            break;
                        case 2:
                            strQ2 = H0.a.q(i4, parcel);
                            break;
                        case 3:
                            strQ5 = H0.a.q(i4, parcel);
                            break;
                        case 4:
                            strQ4 = H0.a.q(i4, parcel);
                            break;
                        case 5:
                            strQ3 = H0.a.q(i4, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            strQ6 = H0.a.q(i4, parcel);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            zS = H0.a.S(i4, parcel);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            strQ7 = H0.a.q(i4, parcel);
                            break;
                        default:
                            H0.a.e0(i4, parcel);
                            break;
                    }
                }
                H0.a.y(iI0, parcel);
                return new c(strQ, strQ2, strQ3, strQ4, strQ5, strQ6, zS, strQ7);
            case 1:
                int iI02 = H0.a.i0(parcel);
                m mVar = null;
                ArrayList arrayListU = null;
                zzafm zzafmVar = null;
                c cVar = null;
                String strQ8 = null;
                String strQ9 = null;
                ArrayList arrayListU2 = null;
                ArrayList arrayListR = null;
                String strQ10 = null;
                Boolean boolValueOf = null;
                f fVar = null;
                boolean zS2 = false;
                C0455E c0455e = null;
                while (parcel.dataPosition() < iI02) {
                    int i5 = parcel.readInt();
                    ArrayList arrayList = arrayListU;
                    switch ((char) i5) {
                        case 1:
                            zzafmVar = (zzafm) H0.a.o(parcel, i5, zzafm.CREATOR);
                            break;
                        case 2:
                            cVar = (c) H0.a.o(parcel, i5, c.CREATOR);
                            break;
                        case 3:
                            strQ8 = H0.a.q(i5, parcel);
                            break;
                        case 4:
                            strQ9 = H0.a.q(i5, parcel);
                            break;
                        case 5:
                            arrayListU2 = H0.a.u(parcel, i5, c.CREATOR);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            arrayListR = H0.a.r(i5, parcel);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            strQ10 = H0.a.q(i5, parcel);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            int iY = H0.a.Y(i5, parcel);
                            if (iY != 0) {
                                H0.a.m0(parcel, iY, 4);
                                boolValueOf = Boolean.valueOf(parcel.readInt() != 0);
                            } else {
                                boolValueOf = null;
                            }
                            break;
                        case '\t':
                            fVar = (f) H0.a.o(parcel, i5, f.CREATOR);
                            break;
                        case '\n':
                            zS2 = H0.a.S(i5, parcel);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            c0455e = (C0455E) H0.a.o(parcel, i5, C0455E.CREATOR);
                            break;
                        case '\f':
                            mVar = (m) H0.a.o(parcel, i5, m.CREATOR);
                            break;
                        case '\r':
                            arrayListU = H0.a.u(parcel, i5, zzafp.CREATOR);
                            continue;
                        default:
                            H0.a.e0(i5, parcel);
                            break;
                    }
                    arrayListU = arrayList;
                }
                H0.a.y(iI02, parcel);
                e eVar = new e();
                eVar.f5512a = zzafmVar;
                eVar.f5513b = cVar;
                eVar.f5514c = strQ8;
                eVar.f5515d = strQ9;
                eVar.e = arrayListU2;
                eVar.f5516f = arrayListR;
                eVar.f5517m = strQ10;
                eVar.f5518n = boolValueOf;
                eVar.f5519o = fVar;
                eVar.f5520p = zS2;
                eVar.f5521q = c0455e;
                eVar.f5522r = mVar;
                eVar.f5523s = arrayListU;
                return eVar;
            case 2:
                int iI03 = H0.a.i0(parcel);
                long jW = 0;
                long jW2 = 0;
                while (parcel.dataPosition() < iI03) {
                    int i6 = parcel.readInt();
                    char c5 = (char) i6;
                    if (c5 == 1) {
                        jW = H0.a.W(i6, parcel);
                    } else if (c5 != 2) {
                        H0.a.e0(i6, parcel);
                    } else {
                        jW2 = H0.a.W(i6, parcel);
                    }
                }
                H0.a.y(iI03, parcel);
                return new f(jW, jW2);
            case 3:
                int iI04 = H0.a.i0(parcel);
                String strQ11 = null;
                String strQ12 = null;
                ArrayList arrayListU3 = null;
                ArrayList arrayListU4 = null;
                e eVar2 = null;
                while (parcel.dataPosition() < iI04) {
                    int i7 = parcel.readInt();
                    char c6 = (char) i7;
                    if (c6 == 1) {
                        strQ11 = H0.a.q(i7, parcel);
                    } else if (c6 == 2) {
                        strQ12 = H0.a.q(i7, parcel);
                    } else if (c6 == 3) {
                        arrayListU3 = H0.a.u(parcel, i7, j1.u.CREATOR);
                    } else if (c6 == 4) {
                        arrayListU4 = H0.a.u(parcel, i7, j1.x.CREATOR);
                    } else if (c6 != 5) {
                        H0.a.e0(i7, parcel);
                    } else {
                        eVar2 = (e) H0.a.o(parcel, i7, e.CREATOR);
                    }
                }
                H0.a.y(iI04, parcel);
                g gVar = new g();
                gVar.f5526a = strQ11;
                gVar.f5527b = strQ12;
                gVar.f5528c = arrayListU3;
                gVar.f5529d = arrayListU4;
                gVar.e = eVar2;
                return gVar;
            case 4:
                int iI05 = H0.a.i0(parcel);
                ArrayList arrayListU5 = null;
                ArrayList arrayListU6 = null;
                while (parcel.dataPosition() < iI05) {
                    int i8 = parcel.readInt();
                    char c7 = (char) i8;
                    if (c7 == 1) {
                        arrayListU5 = H0.a.u(parcel, i8, j1.u.CREATOR);
                    } else if (c7 != 2) {
                        H0.a.e0(i8, parcel);
                    } else {
                        arrayListU6 = H0.a.u(parcel, i8, j1.x.CREATOR);
                    }
                }
                H0.a.y(iI05, parcel);
                return new m(arrayListU5, arrayListU6);
            case 5:
                int iI06 = H0.a.i0(parcel);
                String strQ13 = null;
                boolean zS3 = false;
                String strQ14 = null;
                while (parcel.dataPosition() < iI06) {
                    int i9 = parcel.readInt();
                    char c8 = (char) i9;
                    if (c8 == 1) {
                        strQ13 = H0.a.q(i9, parcel);
                    } else if (c8 == 2) {
                        strQ14 = H0.a.q(i9, parcel);
                    } else if (c8 != 3) {
                        H0.a.e0(i9, parcel);
                    } else {
                        zS3 = H0.a.S(i9, parcel);
                    }
                }
                H0.a.y(iI06, parcel);
                return new w(strQ13, strQ14, zS3);
            default:
                int iI07 = H0.a.i0(parcel);
                e eVar3 = null;
                w wVar = null;
                C0455E c0455e2 = null;
                while (parcel.dataPosition() < iI07) {
                    int i10 = parcel.readInt();
                    char c9 = (char) i10;
                    if (c9 == 1) {
                        eVar3 = (e) H0.a.o(parcel, i10, e.CREATOR);
                    } else if (c9 == 2) {
                        wVar = (w) H0.a.o(parcel, i10, w.CREATOR);
                    } else if (c9 != 3) {
                        H0.a.e0(i10, parcel);
                    } else {
                        c0455e2 = (C0455E) H0.a.o(parcel, i10, C0455E.CREATOR);
                    }
                }
                H0.a.y(iI07, parcel);
                x xVar = new x();
                xVar.f5555a = eVar3;
                xVar.f5556b = wVar;
                xVar.f5557c = c0455e2;
                return xVar;
        }
    }

    @Override // android.os.Parcelable.Creator
    public final /* synthetic */ Object[] newArray(int i4) {
        switch (this.f5504a) {
            case 0:
                return new c[i4];
            case 1:
                return new e[i4];
            case 2:
                return new f[i4];
            case 3:
                return new g[i4];
            case 4:
                return new m[i4];
            case 5:
                return new w[i4];
            default:
                return new x[i4];
        }
    }
}
