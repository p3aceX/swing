package O;

import X.C0182m;
import a.AbstractC0184a;
import android.accounts.Account;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.IntentSender;
import android.net.Uri;
import android.os.Bundle;
import android.os.IBinder;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import androidx.versionedparcelable.ParcelImpl;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.C0286i;
import com.google.android.gms.common.internal.C0287j;
import com.google.android.gms.common.internal.C0294q;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.internal.p002firebaseauthapi.zzagq;
import d.C0321a;
import j1.C0451A;
import java.util.ArrayList;
import z0.C0771b;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class O implements Parcelable.Creator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1261a;

    public /* synthetic */ O(int i4) {
        this.f1261a = i4;
    }

    public static void a(C0287j c0287j, Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(c0287j.f3569a);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(c0287j.f3570b);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(c0287j.f3571c);
        AbstractC0184a.i0(parcel, 4, c0287j.f3572d, false);
        IBinder iBinder = c0287j.e;
        if (iBinder != null) {
            int iM02 = AbstractC0184a.m0(5, parcel);
            parcel.writeStrongBinder(iBinder);
            AbstractC0184a.n0(iM02, parcel);
        }
        AbstractC0184a.k0(parcel, 6, c0287j.f3573f, i4);
        AbstractC0184a.b0(parcel, 7, c0287j.f3574m, false);
        AbstractC0184a.h0(parcel, 8, c0287j.f3575n, i4, false);
        AbstractC0184a.k0(parcel, 10, c0287j.f3576o, i4);
        AbstractC0184a.k0(parcel, 11, c0287j.f3577p, i4);
        AbstractC0184a.o0(parcel, 12, 4);
        parcel.writeInt(c0287j.f3578q ? 1 : 0);
        AbstractC0184a.o0(parcel, 13, 4);
        parcel.writeInt(c0287j.f3579r);
        boolean z4 = c0287j.f3580s;
        AbstractC0184a.o0(parcel, 14, 4);
        parcel.writeInt(z4 ? 1 : 0);
        AbstractC0184a.i0(parcel, 15, c0287j.f3581t, false);
        AbstractC0184a.n0(iM0, parcel);
    }

    @Override // android.os.Parcelable.Creator
    public final Object createFromParcel(Parcel parcel) {
        switch (this.f1261a) {
            case 0:
                P p4 = new P();
                p4.e = null;
                p4.f1266f = new ArrayList();
                p4.f1267m = new ArrayList();
                p4.f1262a = parcel.createStringArrayList();
                p4.f1263b = parcel.createStringArrayList();
                p4.f1264c = (C0091b[]) parcel.createTypedArray(C0091b.CREATOR);
                p4.f1265d = parcel.readInt();
                p4.e = parcel.readString();
                p4.f1266f = parcel.createStringArrayList();
                p4.f1267m = parcel.createTypedArrayList(C0092c.CREATOR);
                p4.f1268n = parcel.createTypedArrayList(J.CREATOR);
                return p4;
            case 1:
                return new T(parcel);
            case 2:
                int iI0 = H0.a.i0(parcel);
                int iU = 0;
                Intent intent = null;
                int iU2 = 0;
                while (parcel.dataPosition() < iI0) {
                    int i4 = parcel.readInt();
                    char c5 = (char) i4;
                    if (c5 == 1) {
                        iU = H0.a.U(i4, parcel);
                    } else if (c5 == 2) {
                        iU2 = H0.a.U(i4, parcel);
                    } else if (c5 != 3) {
                        H0.a.e0(i4, parcel);
                    } else {
                        intent = (Intent) H0.a.o(parcel, i4, Intent.CREATOR);
                    }
                }
                H0.a.y(iI0, parcel);
                return new P0.b(iU, iU2, intent);
            case 3:
                int iI02 = H0.a.i0(parcel);
                ArrayList arrayListR = null;
                String strQ = null;
                while (parcel.dataPosition() < iI02) {
                    int i5 = parcel.readInt();
                    char c6 = (char) i5;
                    if (c6 == 1) {
                        arrayListR = H0.a.r(i5, parcel);
                    } else if (c6 != 2) {
                        H0.a.e0(i5, parcel);
                    } else {
                        strQ = H0.a.q(i5, parcel);
                    }
                }
                H0.a.y(iI02, parcel);
                return new P0.e(strQ, arrayListR);
            case 4:
                int iI03 = H0.a.i0(parcel);
                int iU3 = 0;
                com.google.android.gms.common.internal.A a5 = null;
                while (parcel.dataPosition() < iI03) {
                    int i6 = parcel.readInt();
                    char c7 = (char) i6;
                    if (c7 == 1) {
                        iU3 = H0.a.U(i6, parcel);
                    } else if (c7 != 2) {
                        H0.a.e0(i6, parcel);
                    } else {
                        a5 = (com.google.android.gms.common.internal.A) H0.a.o(parcel, i6, com.google.android.gms.common.internal.A.CREATOR);
                    }
                }
                H0.a.y(iI03, parcel);
                return new P0.f(iU3, a5);
            case 5:
                int iI04 = H0.a.i0(parcel);
                int iU4 = 0;
                C0771b c0771b = null;
                com.google.android.gms.common.internal.B b5 = null;
                while (parcel.dataPosition() < iI04) {
                    int i7 = parcel.readInt();
                    char c8 = (char) i7;
                    if (c8 == 1) {
                        iU4 = H0.a.U(i7, parcel);
                    } else if (c8 == 2) {
                        c0771b = (C0771b) H0.a.o(parcel, i7, C0771b.CREATOR);
                    } else if (c8 != 3) {
                        H0.a.e0(i7, parcel);
                    } else {
                        b5 = (com.google.android.gms.common.internal.B) H0.a.o(parcel, i7, com.google.android.gms.common.internal.B.CREATOR);
                    }
                }
                H0.a.y(iI04, parcel);
                return new P0.g(iU4, c0771b, b5);
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                C0182m c0182m = new C0182m();
                c0182m.f2363a = parcel.readInt();
                c0182m.f2364b = parcel.readInt();
                c0182m.f2365c = parcel.readInt() == 1;
                return c0182m;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                X.H h4 = new X.H();
                h4.f2286a = parcel.readInt();
                h4.f2287b = parcel.readInt();
                h4.f2289d = parcel.readInt() == 1;
                int i8 = parcel.readInt();
                if (i8 > 0) {
                    int[] iArr = new int[i8];
                    h4.f2288c = iArr;
                    parcel.readIntArray(iArr);
                }
                return h4;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                X.I i9 = new X.I();
                i9.f2290a = parcel.readInt();
                i9.f2291b = parcel.readInt();
                int i10 = parcel.readInt();
                i9.f2292c = i10;
                if (i10 > 0) {
                    int[] iArr2 = new int[i10];
                    i9.f2293d = iArr2;
                    parcel.readIntArray(iArr2);
                }
                int i11 = parcel.readInt();
                i9.e = i11;
                if (i11 > 0) {
                    int[] iArr3 = new int[i11];
                    i9.f2294f = iArr3;
                    parcel.readIntArray(iArr3);
                }
                i9.f2296n = parcel.readInt() == 1;
                i9.f2297o = parcel.readInt() == 1;
                i9.f2298p = parcel.readInt() == 1;
                i9.f2295m = parcel.readArrayList(X.H.class.getClassLoader());
                return i9;
            case 9:
                int iI05 = H0.a.i0(parcel);
                String strQ2 = null;
                int iU5 = 0;
                while (parcel.dataPosition() < iI05) {
                    int i12 = parcel.readInt();
                    char c9 = (char) i12;
                    if (c9 == 1) {
                        iU5 = H0.a.U(i12, parcel);
                    } else if (c9 != 2) {
                        H0.a.e0(i12, parcel);
                    } else {
                        strQ2 = H0.a.q(i12, parcel);
                    }
                }
                H0.a.y(iI05, parcel);
                return new Scope(iU5, strQ2);
            case 10:
                int iI06 = H0.a.i0(parcel);
                String strQ3 = null;
                PendingIntent pendingIntent = null;
                C0771b c0771b2 = null;
                int iU6 = 0;
                int iU7 = 0;
                while (parcel.dataPosition() < iI06) {
                    int i13 = parcel.readInt();
                    char c10 = (char) i13;
                    if (c10 == 1) {
                        iU7 = H0.a.U(i13, parcel);
                    } else if (c10 == 2) {
                        strQ3 = H0.a.q(i13, parcel);
                    } else if (c10 == 3) {
                        pendingIntent = (PendingIntent) H0.a.o(parcel, i13, PendingIntent.CREATOR);
                    } else if (c10 == 4) {
                        c0771b2 = (C0771b) H0.a.o(parcel, i13, C0771b.CREATOR);
                    } else if (c10 != 1000) {
                        H0.a.e0(i13, parcel);
                    } else {
                        iU6 = H0.a.U(i13, parcel);
                    }
                }
                H0.a.y(iI06, parcel);
                return new Status(iU6, iU7, strQ3, pendingIntent, c0771b2);
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                int iI07 = H0.a.i0(parcel);
                int iU8 = 0;
                ArrayList arrayListU = null;
                while (parcel.dataPosition() < iI07) {
                    int i14 = parcel.readInt();
                    char c11 = (char) i14;
                    if (c11 == 1) {
                        iU8 = H0.a.U(i14, parcel);
                    } else if (c11 != 2) {
                        H0.a.e0(i14, parcel);
                    } else {
                        arrayListU = H0.a.u(parcel, i14, C0294q.CREATOR);
                    }
                }
                H0.a.y(iI07, parcel);
                return new com.google.android.gms.common.internal.v(iU8, arrayListU);
            case 12:
                int iI08 = H0.a.i0(parcel);
                int iU9 = 0;
                int iU10 = 0;
                int iU11 = 0;
                int iU12 = 0;
                long jW = 0;
                long jW2 = 0;
                String strQ4 = null;
                String strQ5 = null;
                int iU13 = -1;
                while (parcel.dataPosition() < iI08) {
                    int i15 = parcel.readInt();
                    switch ((char) i15) {
                        case 1:
                            iU9 = H0.a.U(i15, parcel);
                            break;
                        case 2:
                            iU10 = H0.a.U(i15, parcel);
                            break;
                        case 3:
                            iU11 = H0.a.U(i15, parcel);
                            break;
                        case 4:
                            jW = H0.a.W(i15, parcel);
                            break;
                        case 5:
                            jW2 = H0.a.W(i15, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            strQ4 = H0.a.q(i15, parcel);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            strQ5 = H0.a.q(i15, parcel);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            iU12 = H0.a.U(i15, parcel);
                            break;
                        case '\t':
                            iU13 = H0.a.U(i15, parcel);
                            break;
                        default:
                            H0.a.e0(i15, parcel);
                            break;
                    }
                }
                H0.a.y(iI08, parcel);
                return new C0294q(iU9, iU10, iU11, jW, jW2, strQ4, strQ5, iU12, iU13);
            case 13:
                int iI09 = H0.a.i0(parcel);
                int iU14 = 0;
                Account account = null;
                GoogleSignInAccount googleSignInAccount = null;
                int iU15 = 0;
                while (parcel.dataPosition() < iI09) {
                    int i16 = parcel.readInt();
                    char c12 = (char) i16;
                    if (c12 == 1) {
                        iU14 = H0.a.U(i16, parcel);
                    } else if (c12 == 2) {
                        account = (Account) H0.a.o(parcel, i16, Account.CREATOR);
                    } else if (c12 == 3) {
                        iU15 = H0.a.U(i16, parcel);
                    } else if (c12 != 4) {
                        H0.a.e0(i16, parcel);
                    } else {
                        googleSignInAccount = (GoogleSignInAccount) H0.a.o(parcel, i16, GoogleSignInAccount.CREATOR);
                    }
                }
                H0.a.y(iI09, parcel);
                return new com.google.android.gms.common.internal.A(iU14, account, iU15, googleSignInAccount);
            case 14:
                int iI010 = H0.a.i0(parcel);
                int iU16 = 0;
                boolean zS = false;
                boolean zS2 = false;
                IBinder strongBinder = null;
                C0771b c0771b3 = null;
                while (parcel.dataPosition() < iI010) {
                    int i17 = parcel.readInt();
                    char c13 = (char) i17;
                    if (c13 == 1) {
                        iU16 = H0.a.U(i17, parcel);
                    } else if (c13 == 2) {
                        int iY = H0.a.Y(i17, parcel);
                        int iDataPosition = parcel.dataPosition();
                        if (iY == 0) {
                            strongBinder = null;
                        } else {
                            strongBinder = parcel.readStrongBinder();
                            parcel.setDataPosition(iDataPosition + iY);
                        }
                    } else if (c13 == 3) {
                        c0771b3 = (C0771b) H0.a.o(parcel, i17, C0771b.CREATOR);
                    } else if (c13 == 4) {
                        zS = H0.a.S(i17, parcel);
                    } else if (c13 != 5) {
                        H0.a.e0(i17, parcel);
                    } else {
                        zS2 = H0.a.S(i17, parcel);
                    }
                }
                H0.a.y(iI010, parcel);
                return new com.google.android.gms.common.internal.B(iU16, strongBinder, c0771b3, zS, zS2);
            case 15:
                int iI011 = H0.a.i0(parcel);
                int iU17 = 0;
                boolean zS3 = false;
                boolean zS4 = false;
                int iU18 = 0;
                int iU19 = 0;
                while (parcel.dataPosition() < iI011) {
                    int i18 = parcel.readInt();
                    char c14 = (char) i18;
                    if (c14 == 1) {
                        iU17 = H0.a.U(i18, parcel);
                    } else if (c14 == 2) {
                        zS3 = H0.a.S(i18, parcel);
                    } else if (c14 == 3) {
                        zS4 = H0.a.S(i18, parcel);
                    } else if (c14 == 4) {
                        iU18 = H0.a.U(i18, parcel);
                    } else if (c14 != 5) {
                        H0.a.e0(i18, parcel);
                    } else {
                        iU19 = H0.a.U(i18, parcel);
                    }
                }
                H0.a.y(iI011, parcel);
                return new com.google.android.gms.common.internal.u(iU17, zS3, zS4, iU18, iU19);
            case 16:
                int iI012 = H0.a.i0(parcel);
                Bundle bundleI = null;
                C0286i c0286i = null;
                int iU20 = 0;
                C0773d[] c0773dArr = null;
                while (parcel.dataPosition() < iI012) {
                    int i19 = parcel.readInt();
                    char c15 = (char) i19;
                    if (c15 == 1) {
                        bundleI = H0.a.i(i19, parcel);
                    } else if (c15 == 2) {
                        c0773dArr = (C0773d[]) H0.a.t(parcel, i19, C0773d.CREATOR);
                    } else if (c15 == 3) {
                        iU20 = H0.a.U(i19, parcel);
                    } else if (c15 != 4) {
                        H0.a.e0(i19, parcel);
                    } else {
                        c0286i = (C0286i) H0.a.o(parcel, i19, C0286i.CREATOR);
                    }
                }
                H0.a.y(iI012, parcel);
                com.google.android.gms.common.internal.L l2 = new com.google.android.gms.common.internal.L();
                l2.f3530a = bundleI;
                l2.f3531b = c0773dArr;
                l2.f3532c = iU20;
                l2.f3533d = c0286i;
                return l2;
            case 17:
                int iI013 = H0.a.i0(parcel);
                com.google.android.gms.common.internal.u uVar = null;
                int[] iArrM = null;
                int[] iArrM2 = null;
                boolean zS5 = false;
                boolean zS6 = false;
                int iU21 = 0;
                while (parcel.dataPosition() < iI013) {
                    int i20 = parcel.readInt();
                    switch ((char) i20) {
                        case 1:
                            uVar = (com.google.android.gms.common.internal.u) H0.a.o(parcel, i20, com.google.android.gms.common.internal.u.CREATOR);
                            break;
                        case 2:
                            zS5 = H0.a.S(i20, parcel);
                            break;
                        case 3:
                            zS6 = H0.a.S(i20, parcel);
                            break;
                        case 4:
                            iArrM = H0.a.m(i20, parcel);
                            break;
                        case 5:
                            iU21 = H0.a.U(i20, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            iArrM2 = H0.a.m(i20, parcel);
                            break;
                        default:
                            H0.a.e0(i20, parcel);
                            break;
                    }
                }
                H0.a.y(iI013, parcel);
                return new C0286i(uVar, zS5, zS6, iArrM, iU21, iArrM2);
            case 18:
                int iI014 = H0.a.i0(parcel);
                Scope[] scopeArr = C0287j.f3568u;
                Bundle bundle = new Bundle();
                C0773d[] c0773dArr2 = C0287j.v;
                C0773d[] c0773dArr3 = c0773dArr2;
                String strQ6 = null;
                IBinder iBinder = null;
                Account account2 = null;
                String strQ7 = null;
                int iU22 = 0;
                int iU23 = 0;
                int iU24 = 0;
                boolean zS7 = false;
                int iU25 = 0;
                boolean zS8 = false;
                while (parcel.dataPosition() < iI014) {
                    int i21 = parcel.readInt();
                    switch ((char) i21) {
                        case 1:
                            iU22 = H0.a.U(i21, parcel);
                            break;
                        case 2:
                            iU23 = H0.a.U(i21, parcel);
                            break;
                        case 3:
                            iU24 = H0.a.U(i21, parcel);
                            break;
                        case 4:
                            strQ6 = H0.a.q(i21, parcel);
                            break;
                        case 5:
                            int iY2 = H0.a.Y(i21, parcel);
                            int iDataPosition2 = parcel.dataPosition();
                            if (iY2 != 0) {
                                IBinder strongBinder2 = parcel.readStrongBinder();
                                parcel.setDataPosition(iDataPosition2 + iY2);
                                iBinder = strongBinder2;
                            } else {
                                iBinder = null;
                            }
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            scopeArr = (Scope[]) H0.a.t(parcel, i21, Scope.CREATOR);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            bundle = H0.a.i(i21, parcel);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            account2 = (Account) H0.a.o(parcel, i21, Account.CREATOR);
                            break;
                        case '\t':
                        default:
                            H0.a.e0(i21, parcel);
                            break;
                        case '\n':
                            c0773dArr2 = (C0773d[]) H0.a.t(parcel, i21, C0773d.CREATOR);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            c0773dArr3 = (C0773d[]) H0.a.t(parcel, i21, C0773d.CREATOR);
                            break;
                        case '\f':
                            zS7 = H0.a.S(i21, parcel);
                            break;
                        case '\r':
                            iU25 = H0.a.U(i21, parcel);
                            break;
                        case 14:
                            zS8 = H0.a.S(i21, parcel);
                            break;
                        case 15:
                            strQ7 = H0.a.q(i21, parcel);
                            break;
                    }
                }
                H0.a.y(iI014, parcel);
                return new C0287j(iU22, iU23, iU24, strQ6, iBinder, scopeArr, bundle, account2, c0773dArr2, c0773dArr3, zS7, iU25, zS8, strQ7);
            case 19:
                return new C0321a(parcel);
            case 20:
                J3.i.e(parcel, "inParcel");
                Parcelable parcelable = parcel.readParcelable(IntentSender.class.getClassLoader());
                J3.i.b(parcelable);
                return new d.d((IntentSender) parcelable, (Intent) parcel.readParcelable(Intent.class.getClassLoader()), parcel.readInt(), parcel.readInt());
            case 21:
                return new ParcelImpl(parcel);
            case 22:
                int iI015 = H0.a.i0(parcel);
                String strQ8 = null;
                while (parcel.dataPosition() < iI015) {
                    int i22 = parcel.readInt();
                    if (((char) i22) != 1) {
                        H0.a.e0(i22, parcel);
                    } else {
                        strQ8 = H0.a.q(i22, parcel);
                    }
                }
                H0.a.y(iI015, parcel);
                return new j1.m(strQ8);
            case 23:
                int iI016 = H0.a.i0(parcel);
                String strQ9 = null;
                String strQ10 = null;
                while (parcel.dataPosition() < iI016) {
                    int i23 = parcel.readInt();
                    char c16 = (char) i23;
                    if (c16 == 1) {
                        strQ9 = H0.a.q(i23, parcel);
                    } else if (c16 != 2) {
                        H0.a.e0(i23, parcel);
                    } else {
                        strQ10 = H0.a.q(i23, parcel);
                    }
                }
                H0.a.y(iI016, parcel);
                return new j1.n(strQ9, strQ10);
            case 24:
                int iI017 = H0.a.i0(parcel);
                String strQ11 = null;
                String strQ12 = null;
                String strQ13 = null;
                String strQ14 = null;
                boolean zS9 = false;
                while (parcel.dataPosition() < iI017) {
                    int i24 = parcel.readInt();
                    char c17 = (char) i24;
                    if (c17 == 1) {
                        strQ11 = H0.a.q(i24, parcel);
                    } else if (c17 == 2) {
                        strQ12 = H0.a.q(i24, parcel);
                    } else if (c17 == 4) {
                        strQ13 = H0.a.q(i24, parcel);
                    } else if (c17 == 5) {
                        zS9 = H0.a.S(i24, parcel);
                    } else if (c17 != 6) {
                        H0.a.e0(i24, parcel);
                    } else {
                        strQ14 = H0.a.q(i24, parcel);
                    }
                }
                H0.a.y(iI017, parcel);
                return new j1.q(strQ11, strQ12, strQ13, strQ14, zS9);
            case 25:
                int iI018 = H0.a.i0(parcel);
                String strQ15 = null;
                String strQ16 = null;
                String strQ17 = null;
                long jW3 = 0;
                while (parcel.dataPosition() < iI018) {
                    int i25 = parcel.readInt();
                    char c18 = (char) i25;
                    if (c18 == 1) {
                        strQ15 = H0.a.q(i25, parcel);
                    } else if (c18 == 2) {
                        strQ16 = H0.a.q(i25, parcel);
                    } else if (c18 == 3) {
                        jW3 = H0.a.W(i25, parcel);
                    } else if (c18 != 4) {
                        H0.a.e0(i25, parcel);
                    } else {
                        strQ17 = H0.a.q(i25, parcel);
                    }
                }
                H0.a.y(iI018, parcel);
                return new j1.u(strQ15, strQ16, jW3, strQ17);
            case 26:
                int iI019 = H0.a.i0(parcel);
                String strQ18 = null;
                while (parcel.dataPosition() < iI019) {
                    int i26 = parcel.readInt();
                    if (((char) i26) != 1) {
                        H0.a.e0(i26, parcel);
                    } else {
                        strQ18 = H0.a.q(i26, parcel);
                    }
                }
                H0.a.y(iI019, parcel);
                return new j1.v(strQ18);
            case 27:
                int iI020 = H0.a.i0(parcel);
                String strQ19 = null;
                String strQ20 = null;
                zzagq zzagqVar = null;
                long jW4 = 0;
                while (parcel.dataPosition() < iI020) {
                    int i27 = parcel.readInt();
                    char c19 = (char) i27;
                    if (c19 == 1) {
                        strQ19 = H0.a.q(i27, parcel);
                    } else if (c19 == 2) {
                        strQ20 = H0.a.q(i27, parcel);
                    } else if (c19 == 3) {
                        jW4 = H0.a.W(i27, parcel);
                    } else if (c19 != 4) {
                        H0.a.e0(i27, parcel);
                    } else {
                        zzagqVar = (zzagq) H0.a.o(parcel, i27, zzagq.CREATOR);
                    }
                }
                H0.a.y(iI020, parcel);
                return new j1.x(strQ19, strQ20, jW4, zzagqVar);
            case 28:
                int iI021 = H0.a.i0(parcel);
                String strQ21 = null;
                String strQ22 = null;
                while (parcel.dataPosition() < iI021) {
                    int i28 = parcel.readInt();
                    char c20 = (char) i28;
                    if (c20 == 1) {
                        strQ21 = H0.a.q(i28, parcel);
                    } else if (c20 != 2) {
                        H0.a.e0(i28, parcel);
                    } else {
                        strQ22 = H0.a.q(i28, parcel);
                    }
                }
                H0.a.y(iI021, parcel);
                return new j1.y(strQ21, strQ22);
            default:
                int iI022 = H0.a.i0(parcel);
                boolean zS10 = false;
                String strQ23 = null;
                String strQ24 = null;
                boolean zS11 = false;
                while (parcel.dataPosition() < iI022) {
                    int i29 = parcel.readInt();
                    char c21 = (char) i29;
                    if (c21 == 2) {
                        strQ23 = H0.a.q(i29, parcel);
                    } else if (c21 == 3) {
                        strQ24 = H0.a.q(i29, parcel);
                    } else if (c21 == 4) {
                        zS10 = H0.a.S(i29, parcel);
                    } else if (c21 != 5) {
                        H0.a.e0(i29, parcel);
                    } else {
                        zS11 = H0.a.S(i29, parcel);
                    }
                }
                H0.a.y(iI022, parcel);
                C0451A c0451a = new C0451A();
                c0451a.f5156a = strQ23;
                c0451a.f5157b = strQ24;
                c0451a.f5158c = zS10;
                c0451a.f5159d = zS11;
                c0451a.e = TextUtils.isEmpty(strQ24) ? null : Uri.parse(strQ24);
                return c0451a;
        }
    }

    @Override // android.os.Parcelable.Creator
    public final Object[] newArray(int i4) {
        switch (this.f1261a) {
            case 0:
                return new P[i4];
            case 1:
                return new T[i4];
            case 2:
                return new P0.b[i4];
            case 3:
                return new P0.e[i4];
            case 4:
                return new P0.f[i4];
            case 5:
                return new P0.g[i4];
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                return new C0182m[i4];
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return new X.H[i4];
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                return new X.I[i4];
            case 9:
                return new Scope[i4];
            case 10:
                return new Status[i4];
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return new com.google.android.gms.common.internal.v[i4];
            case 12:
                return new C0294q[i4];
            case 13:
                return new com.google.android.gms.common.internal.A[i4];
            case 14:
                return new com.google.android.gms.common.internal.B[i4];
            case 15:
                return new com.google.android.gms.common.internal.u[i4];
            case 16:
                return new com.google.android.gms.common.internal.L[i4];
            case 17:
                return new C0286i[i4];
            case 18:
                return new C0287j[i4];
            case 19:
                return new C0321a[i4];
            case 20:
                return new d.d[i4];
            case 21:
                return new ParcelImpl[i4];
            case 22:
                return new j1.m[i4];
            case 23:
                return new j1.n[i4];
            case 24:
                return new j1.q[i4];
            case 25:
                return new j1.u[i4];
            case 26:
                return new j1.v[i4];
            case 27:
                return new j1.x[i4];
            case 28:
                return new j1.y[i4];
            default:
                return new C0451A[i4];
        }
    }
}
