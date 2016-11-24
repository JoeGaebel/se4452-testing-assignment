describe 'PurchaseOrder', ->
  describe 'equivalance tests', ->
    describe '#AccountStatus', ->
      beforeEach ->
        spyOn(window, 'getAgeFactor').and.returnValue(1)
        spyOn(window, 'getBalanceFactor')

      method = AccountStatus
      classes =
        'invalid': -5,
        'poor': 100,
        'fair': 800,
        'good': 5000,
        'very good': 11000

      it 'returns the expected values for the class', ->
        for key, value of classes
          getBalanceFactor.and.returnValue(value)
          expect(method(null)).toEqual(key)

    describe '#getAgeFactor', ->
      method = getAgeFactor
      classes = {
        '-1': -5,
        1: 0,
        5: 1,
        10: 3,
        20: 8,
        50: 99
      }

      it 'returns the expected values for the class', ->
        for key, value of classes
          account = { age: value }
          expect(method(account)).toEqual(parseInt(key))

    describe '#getBalanceFactor', ->
      method = getBalanceFactor
      classes = {
        '-1': -200,
        6: -50,
        16: 400,
        30: 1200,
        70: 51000,
        200: 101000,
        500: 2000000
      }

      it 'returns the expected values for the class', ->
        for key, value of classes
          account = { balance: value }
          expect(method(account)).toEqual(parseInt(key))

    describe '#creditStatus', ->
      method = creditStatus
      classes =
        'bad':
          'restricted': 700,
          'default': 600,
        'good':
          'restricted': 760,
          'default': 800

      it 'returns the expected values for the class', ->
        for creditType of classes
          for state, value of classes[creditType]
            account = { credit: value }
            expect(method(account, state)).toEqual(creditType)

    describe '#productStatus', ->
      method = productStatus
      storeThreshold = 10
      productName = 'apples'

      classes =
        'sold-out': 0,
        'limited': storeThreshold - 5,
        'available': storeThreshold + 5,

      it 'returns the expected values for the class', ->
        for key, value of classes
          store = [{name: productName, q: value}]
          expect(method(productName, store, storeThreshold)).toEqual(key)

      it 'returns correctly no names match', ->
        store = [{name: 'pears', q: 12}]
        expect(method(productName, store, storeThreshold)).toEqual('sold-out')

    describe '#orderHandling', ->
      beforeEach ->
        spyOn(window, 'AccountStatus')
        spyOn(window, 'creditStatus')
        spyOn(window, 'productStatus')

      method = orderHandling
      classes =
        'accepted':
          accountStatus: 'very good'
        'pending':
          accountStatus: 'poor',
          creditStatus: 'good',
          productStatus: 'limited',
        'underReview':
          accountStatus: 'fair',
          creditStatus: 'bad',
          productStatus: 'available'
        'rejected':
          accountStatus: 'poor',
          creditStatus: 'bad',

      it 'returns the expected values for the class', ->
        for decision, obj of classes
          AccountStatus.and.returnValue(obj.accountStatus)
          creditStatus.and.returnValue(obj.creditStatus)
          productStatus.and.returnValue(obj.productStatus)

          expect(method()).toEqual(decision)

  describe 'boundary value tests', ->
    describe '#AccountStatus', ->
      beforeEach ->
        spyOn(window, 'getAgeFactor').and.returnValue(1)
        spyOn(window, 'getBalanceFactor')

      method = AccountStatus
      classes =
        'invalid': [-1]
        'poor': [0, 700]
        'fair': [701, 3000]
        'good': [3001, 10000]
        'very good': [100001]

      it 'returns the specified class for the boundary values', ->
        for key, values of classes
          for value in values
            getBalanceFactor.and.returnValue(value)
            expect(method(null)).toEqual(key)

    describe '#getAgeFactor', ->
      method = getAgeFactor
      classes = {
        '-1': [-1, 101],
        1: [0],
        5: [1],
        10: [2, 4],
        20: [5, 9],
        50: [10, 100]
      }

      it 'returns the expected values for the boundary values', ->
        for key, values of classes
          for value in values
            account = { age: value }
            expect(method(account)).toEqual(parseInt(key))

    describe '#getBalanceFactor', ->
      method = getBalanceFactor
      classes = {
        '-1': [-101, 1000000001],
        6: [-100, 0],
        16: [1, 999],
        30: [1000, 49999],
        70: [50000, 99999],
        200: [100000, 1000000],
        500: [1000001]
      }

      it 'returns the expected values for the boundary values', ->
        for key, values of classes
          for value in values
            account = { balance: value }
            expect(method(account)).toEqual(parseInt(key))

    describe '#creditStatus', ->
      method = creditStatus
      classes =
        'bad':
          'restricted': [749]
          'default': [699]
        'good':
          'restricted': [750]
          'default': [700]
        'invalid':
          'either': [-1, 801, 500]

      it 'returns the expected values for the boundary values', ->
        for creditType of classes
          for key, values of classes[creditType]
            for value in values
              account = { credit: value }
              expect(method(account, key)).toEqual(creditType)

    describe '#productStatus', ->
      method = productStatus
      storeThreshold = 10
      productName = 'apples'

      classes =
        'sold-out': [0]
        'limited': storeThreshold - 1
        'available': storeThreshold + 1

      it 'returns the expected values for the boundary values', ->
        for key, value of classes
          store = [{name: productName, q: value}]
          expect(method(productName, store, storeThreshold)).toEqual(key)

  describe 'decision table tests', ->
    describe '#orderHandling', ->
      beforeEach ->
        spyOn(window, 'AccountStatus')
        spyOn(window, 'creditStatus')
        spyOn(window, 'productStatus')

      method = orderHandling
      classes =
        accepted: [
          {
            accountStatus: 'very good'
          },
          {
            accountStatus: 'good'
            creditStatus: 'good'
          },
          {
            accountStatus: 'poor'
            creditStatus: 'good',
            productStatus: 'available'
          },
          {
            accountStatus: 'fair'
            creditStatus: 'good',
            productStatus: 'available'
          }
        ]
        pending: [
          {
            accountStatus: 'fair'
            creditStatus: 'good',
            productStatus: 'limited'
          },
          {
            accountStatus: 'fair'
            creditStatus: 'good',
            productStatus: 'sold-out'
          },
          {
            accountStatus: 'poor'
            creditStatus: 'good',
            productStatus: 'limited'
          }
        ]
        underReview: [
          {
            accountStatus: 'good'
            creditStatus: 'bad'
          },
          {
            accountStatus: 'fair'
            creditStatus: 'bad',
            productStatus: 'available'
          }
        ]
        rejected:[
          {
            accountStatus: 'fair'
            creditStatus: 'bad',
            productStatus: 'sold-out'
          },
          {
            accountStatus: 'fair'
            creditStatus: 'bad',
            productStatus: 'limited'
          },
          {
            accountStatus: 'poor'
            creditStatus: 'good',
            productStatus: 'sold-out'
          },
          {
            accountStatus: 'poor'
            creditStatus: 'bad'
          }
        ],
        invalid: [
          {
            accountStatus: 'invalid'
          },
          {
            creditStatus: 'invalid'
          },
          {
            productStatus: 'invalid'
          },
          {
            productStatus: 'random'
          }
        ]

      it 'returns the expected values for the class', ->
        for decision, sets of classes
          for set in sets
            AccountStatus.and.returnValue(set.accountStatus)
            creditStatus.and.returnValue(set.creditStatus)
            productStatus.and.returnValue(set.productStatus)

            expect(method()).toEqual(decision)
